import csv
import yaml
import random
import argparse

def calculate_crc(frame):
    """
    Calculate the CRC for the given CAN frame using the polynomial:
    x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
    """
    polynomial = 0b1100010110011001  # Generator polynomial
    crc = 0
    for bit in frame:
        crc <<= 1
        if int(bit) ^ (crc >> 15):   # XOR with MSB
            crc ^= polynomial
        crc &= 0x7FFF
    return bin(crc)[2:].zfill(15)

def apply_bit_stuffing(frame):
    stuffed_frame = []
    stuffed_positions = []
    prev_bit = frame[0]
    curr_bit = '0'
    bit_stuff_count = 0
    stuff_cnt = 0

    for i in range(len(frame)):
        curr_bit = frame[i]
        stuffed_frame.append(curr_bit)
        #print(curr_bit)

        if prev_bit == curr_bit:
            bit_stuff_count += 1
        else:
            bit_stuff_count = 1

        if bit_stuff_count == 5:
            stuff_bit = '1' if curr_bit == '0' else '0'
            stuffed_frame.append(stuff_bit)
            stuffed_positions.append(len(stuffed_frame) - 1) # Get the stuffed bit position for implementation of bit stuff error
            #print(f"S{stuff_bit}")
            stuff_cnt += 1
            bit_stuff_count = 1 if stuff_bit == frame[min(i + 1, len(frame) - 1)] else 0 # Check the next bit to ensure the counter is correct
            prev_bit = stuff_bit
        else:
            prev_bit = curr_bit

    return "".join(stuffed_frame), stuff_cnt, stuffed_positions

def implement_error(frame, error_type, stuffed_positions, bus_idle):
    frame_bits = frame["stuffed_frame"]
    error_positions = 0
    modified_frame = frame.copy()
    
    if error_type == "stuff":
        modified_bits = list(frame_bits)
        if stuffed_positions:
            error_positions = random.choice(stuffed_positions)
            start = max(0, error_positions - 5)
            prev_bits = modified_bits[start:error_positions]
            if len(prev_bits) == 5 and all(b == prev_bits[0] for b in prev_bits):
                modified_bits[error_positions] = prev_bits[0]
            else:
                modified_bits[error_positions] = '0' if modified_bits[error_positions] == '1' else '1'
        else:
            error_positions = random.randint(1, len(frame_bits) - 13 - bus_idle - 6)
            prev_bit = modified_bits[error_positions - 1]
            stuff_error_bits = ['0' if prev_bit == '1' else '1'] * 6
            modified_bits = (
                modified_bits[:error_positions] + 
                stuff_error_bits + 
                modified_bits[error_positions:-6]
            )
        modified_frame["stuffed_frame"] = "".join(modified_bits)

    elif error_type == "form":
        eof_start = len(frame_bits) - 10 - bus_idle
        eof_end = eof_start + 8
        eof_error_location = random.randint(eof_start, eof_end - 1)

        possible_locations = [
            len(frame_bits) - 13 - bus_idle,  # CRC delimiter
            len(frame_bits) - 11 - bus_idle,  # ACK delimiter
            eof_error_location
        ]
        error_positions = random.choice(possible_locations)
            
        modified_bits = list(frame_bits)
        modified_bits[error_positions] = '0' if modified_bits[error_positions] == '1' else '1'
        modified_frame["stuffed_frame"] = "".join(modified_bits)

    elif error_type == "ack":
        error_positions = len(frame_bits) - 12 - bus_idle
        modified_bits = list(frame_bits)
        modified_bits[error_positions] = '1'
        modified_frame["stuffed_frame"] = "".join(modified_bits)
    
    elif error_type == "crc":
        crc_start = len(frame_bits) - 28 - bus_idle
        crc_end = crc_start + 15
        modified_bits = list(frame_bits)
        done = False

        while not done:
            available_positions = [pos for pos in range(crc_start, crc_end) if pos not in stuffed_positions]
            error_positions = random.sample(available_positions, random.randint(1, len(available_positions))) # Available positions in CRC range, excluding stuffed positions

            error_positions_values = [modified_bits[i] for i in error_positions]
            flipped_error_position_values = ['1' if value == '0' else '0' for value in error_positions_values] # Flip the values at these positions

            for i in range(len(error_positions)):
                modified_bits[error_positions[i]] = flipped_error_position_values[i] # Add the flipped bits to the modified bits
            
            _, _, new_stuffed_positions = apply_bit_stuffing(''.join(modified_bits[:crc_end])) # Check if flipping causes bit stuff errors
            if len(new_stuffed_positions) == len(stuffed_positions):
                done = True
            else:
                for i in range(len(error_positions)):
                    modified_bits[error_positions[i]] = error_positions_values[i] # Revert the flipped values, since the flipping caused bit stuff errors

        modified_frame["stuffed_frame"] = "".join(modified_bits)

    modified_frame["error_type"] = error_type
    modified_frame["error_locations"] = error_positions
    return modified_frame

def generate_data_frame(frame_id, id_type, dlc, data_bytes, bus_idle):
    if id_type == "standard":
        identifier = bin(frame_id)[2:].zfill(11) # Identifier (11 bits)
        sof = "0"                                # Start-of-frame (SOF): Dominant
        rtr = "0"                                # Remote transmission request (RTR): Dominant for data frames
        ide = "0"                                # Identifier extension bit (IDE): Dominant for standard frames
        reserved_bit = "0"                       # Reserved bit (r0): Set to dominant

        dlc_bin = bin(dlc)[2:].zfill(4)

        data_field = "".join(bin(int(byte, 16))[2:].zfill(8) for byte in data_bytes)

        frame = f"{sof}{identifier}{rtr}{ide}{reserved_bit}{dlc_bin}{data_field}"

        crc = calculate_crc(frame)

        frame_with_crc = frame + crc

        if bus_idle:
            trailing_bits = "10" + "1" * 11  + "1" * bus_idle # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS) + bus idle lenght
        else:
            trailing_bits = "10" + "1" * 11 # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS)

        stuffed_frame, stuffed_bits_count, stuffed_positions = apply_bit_stuffing(frame_with_crc)

        return {
            "stuffed_bits_count": stuffed_bits_count,
            "id_hex": hex(frame_id),
            "id_bin": f"{identifier}",
            "dlc": dlc,
            "data": data_bytes,
            "crc_bin": crc,
            "crc_hex": hex(int(crc, 2)),
            "stuffed_frame": stuffed_frame + trailing_bits,
            "stuffed_positions": stuffed_positions
        }
    
    elif id_type == "extended":
        identifier_a = bin((frame_id >> 18) & 0x7FF)[2:].zfill(11)  # Identifier A (11 bits)
        identifier_b = bin(frame_id & 0x3FFFF)[2:].zfill(18)        # Identifier B (18 bits)
        sof = "0"                                                   # Start-of-frame (SOF): Dominant
        srr = "1"                                                   # Substitute remote request (SRR): Recessive
        ide = "1"                                                   # Identifier extension bit (IDE): Recessive for extended frames
        rtr = "0"                                                   # Remote transmission request (RTR): Recessive for data frames
        reserved_bits = "00"                                        # Reserved bits (r1, r0): Set to dominant

        dlc_bin = bin(dlc)[2:].zfill(4)

        data_field = "".join(bin(int(byte, 16))[2:].zfill(8) for byte in data_bytes)

        frame = f"{sof}{identifier_a}{srr}{ide}{identifier_b}{rtr}{reserved_bits}{dlc_bin}{data_field}"

        crc = calculate_crc(frame)

        frame_with_crc = frame + crc

        if bus_idle:
            trailing_bits = "10" + "1" * 11  + "1" * bus_idle # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS) + bus idle lenght
        else:
            trailing_bits = "10" + "1" * 11 # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS)

        stuffed_frame, stuffed_bits_count, stuffed_positions = apply_bit_stuffing(frame_with_crc)

        return {
            "stuffed_bits_count": stuffed_bits_count,
            "id_hex": hex(frame_id),
            "id_bin": f"{identifier_a}_{identifier_b}",
            "dlc": dlc,
            "data": data_bytes,
            "crc_bin": crc,
            "crc_hex": hex(int(crc, 2)),
            "stuffed_frame": stuffed_frame + trailing_bits,
            "stuffed_positions": stuffed_positions
        }

def generate_remote_frame(frame_id, id_type, dlc, bus_idle):
    if id_type == "standard":
        identifier = bin(frame_id)[2:].zfill(11) # Identifier (11 bits)
        sof = "0"                                # Start-of-frame (SOF): Dominant
        rtr = "1"                                # Remote transmission request (RTR): Recessive for remote frames
        ide = "0"                                # Identifier extension bit (IDE): Dominant for standard id frames
        reserved_bit = "0"                       # Reserved bit (r0): Set to dominant

        dlc_bin = bin(dlc)[2:].zfill(4)          # DLC of the requested message, not the transmitted one

        frame = f"{sof}{identifier}{rtr}{ide}{reserved_bit}{dlc_bin}"

        crc = calculate_crc(frame)

        frame_with_crc = frame + crc

        if bus_idle:
            trailing_bits = "10" + "1" * 11  + "1" * bus_idle # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS) + bus idle lenght
        else:
            trailing_bits = "10" + "1" * 11 # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS)

        stuffed_frame, stuffed_bits_count, stuffed_positions = apply_bit_stuffing(frame_with_crc)

        return {
            "stuffed_bits_count": stuffed_bits_count,
            "id_hex": hex(frame_id),
            "id_bin": f"{identifier}",
            "dlc": dlc,
            "crc_bin": crc,
            "crc_hex": hex(int(crc, 2)),
            "stuffed_frame": stuffed_frame + trailing_bits,
            "stuffed_positions": stuffed_positions
        }
    
    elif id_type == "extended":
        identifier_a = bin((frame_id >> 18) & 0x7FF)[2:].zfill(11)  # Identifier A (11 bits)
        identifier_b = bin(frame_id & 0x3FFFF)[2:].zfill(18)        # Identifier B (18 bits)
        sof = "0"                                                   # Start-of-frame (SOF): Dominant
        srr = "1"                                                   # Substitute remote request (SRR): Recessive
        ide = "1"                                                   # Identifier extension bit (IDE): Recessive for extended frames
        rtr = "1"                                                   # Remote transmission request (RTR): Recessive for remote frames
        reserved_bits = "00"                                        # Reserved bits (r1, r0): Set to dominant

        dlc_bin = bin(dlc)[2:].zfill(4)                             # DLC of the requested message, not the transmitted one

        frame = f"{sof}{identifier_a}{srr}{ide}{identifier_b}{rtr}{reserved_bits}{dlc_bin}"

        crc = calculate_crc(frame)

        frame_with_crc = frame + crc

        if bus_idle:
            trailing_bits = "10" + "1" * 11  + "1" * bus_idle # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS) + bus idle lenght
        else:
            trailing_bits = "10" + "1" * 11 # CRC delimiter + ACK slot + (ACK delimiter + EOF + IFS)

        stuffed_frame, stuffed_bits_count, stuffed_positions = apply_bit_stuffing(frame_with_crc)

        return {
            "stuffed_bits_count": stuffed_bits_count,
            "id_hex": hex(frame_id),
            "id_bin": f"{identifier_a}_{identifier_b}",
            "dlc": dlc,
            "crc_bin": crc,
            "crc_hex": hex(int(crc, 2)),
            "stuffed_frame": stuffed_frame + trailing_bits,
            "stuffed_positions": stuffed_positions
        }
    
def generate_error_frame():
        superpositioned_error_flag = random.randint(6, 12)  # As specified in the CAN bus protocol, an error flag consists of min. 6 and max. 12 dominant bits
        error_flag = "0" * superpositioned_error_flag
        error_delimiter = "1" * 8
        extended_ifs = "1" * 11 # Intermission (3 recessive bits) + suspend transmission (8 recessive bits)                  

        error_frame = f"{error_flag}{error_delimiter}{extended_ifs}"

        return {
            "error_frame": error_frame,
            "error_flag_length": error_flag
        }

def save_to_csv(frames, filename_with):
    with open(filename_with, mode="w", newline="") as file:
        writer = csv.writer(file)
        
        for frame in frames:
            for bit in frame["stuffed_frame"]:
                writer.writerow([bit])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="Path to the yaml config file")
    args = parser.parse_args()

    if not args.path:
        print("Wrong or no path specified. Please specifiy a path to the yaml config file using '-p' or '--path'. For more information refer to '--help'")
        return

    with open(args.path) as stream:
        yaml_data = yaml.safe_load(stream)
    
    frames = []
    frame_number = 0
    for frame in yaml_data['Frames']:
        frame_type = frame.get('type', 'data')
        bus_idle = frame.get('bus_idle', 0)
        error_type = frame.get('error', None)

        frame_number += 1

        if frame['id'] < 2047:  # 2^11
            id_type = "standard"
        elif frame['id'] > 2047 and frame['id'] < 536870911:  # 2^29
            id_type = "extended"
        else:
            print("ID is outside of range")
            return
        
        data_bytes = []
        for byte in frame['data']:
            data_bytes.append(f"{byte:02x}")

        if frame_type == "data": 
            frame_without_error = generate_data_frame(frame['id'], id_type, frame['dlc'], data_bytes, bus_idle)
            if error_type: # Data frame with errors
                frame_with_error = implement_error(frame_without_error.copy(), error_type, frame_without_error["stuffed_positions"], bus_idle)
                error_locations = frame_with_error["error_locations"]
                error_frame, error_flag_length = generate_error_frame().values()
                if error_type == "crc" or error_type == "ack": # The reason for specific handling of crc errorand ack error is that the error flag starts at the bit following ACK delimiter
                    ack_delimiter = len(frame_with_error["stuffed_frame"]) - 11 - bus_idle
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:ack_delimiter]
                    combined_frame = {"stuffed_frame": frame_before_error_flag + error_frame}
                else:
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:error_locations+1]
                    combined_frame = {"stuffed_frame": frame_before_error_flag + error_frame}
                frames.append(combined_frame) # Frame with error frame
                frames.append(frame_without_error) # Same frame without error
            else: # Data frame without errors
                frames.append(frame_without_error)

        elif frame_type == "remote": # Remote frame without errors
            frame_without_error = generate_remote_frame(frame['id'], id_type, frame['dlc'], bus_idle)
            if error_type: # remote frame with errors
                frame_with_error = implement_error(frame_without_error.copy(), error_type, frame_without_error["stuffed_positions"], bus_idle)
                error_locations = frame_with_error["error_locations"]
                error_frame, error_flag_length = generate_error_frame().values()
                if error_type == "crc" or error_type == "ack": # The reason for specific handling of crc errorand ack error is that the error flag starts at the bit following ACK delimiter
                    ack_delimiter = len(frame_with_error["stuffed_frame"]) - 11 - bus_idle
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:ack_delimiter]
                    combined_frame = {"stuffed_frame": frame_before_error_flag + error_frame}
                else:
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:error_locations+1]
                    combined_frame = {"stuffed_frame": frame_before_error_flag + error_frame}
                frames.append(combined_frame) # Frame with error frame
                frames.append(frame_without_error) # Same frame without error
            else: # Remote frame without errors
                frames.append(frame_without_error)

        print(f"\nFrame {frame_number}:")
        print(f"Bus idle lenght: {bus_idle}")
        print(f"Error type: {error_type}")
        print(f"Frame type: {frame_type}")
        print(f"Number of stuffed bits: {frame_without_error['stuffed_bits_count']}")
        print(f"ID (hex): {frame_without_error['id_hex']}")
        print(f"ID (bin): {frame_without_error['id_bin']}")
        print(f"DLC: {frame_without_error['dlc']}")
        if frame_type == "data":
            print(f"Data: {frame_without_error['data']}")
        print(f"CRC (bin): {frame_without_error['crc_bin']}")
        print(f"CRC (hex): {frame_without_error['crc_hex']}")
        if error_type:
            print(f"Length of the error flag is: {len(error_flag_length)}")
            print(f"Frame {frame_number} with error:    {frame_with_error['stuffed_frame']}")
            if error_type == "crc":
                error_indicators = [' '] * len(frame_with_error['stuffed_frame'])
                for loc in frame_with_error["error_locations"]:
                    error_indicators[loc] = '^'
                print(f"Error:                 {''.join(error_indicators)}")
            else:
                print(f"Error:                {' ' * (frame_with_error['error_locations'] + 1)}^")
            print(f"Frame {frame_number} without error: {frame_without_error['stuffed_frame']}\n")

    save_to_csv(frames, f"can_message.csv")

if __name__ == "__main__":
    main()