import os
import csv
import yaml
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

def generate_can_frame(frame_id, frame_type, dlc, data_bytes, is_last_frame=False):
    if frame_type == "standard":
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

        if is_last_frame:
            trailing_bits = "1" * 10  # CRC delimiter + ACK slot + ACK delimiter + EOF
        else:
            trailing_bits = "1" * 13  # CRC delimiter + ACK slot + ACK delimiter + EOF + IFS

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
    
    elif frame_type == "extended":
        identifier_a = bin((frame_id >> 18) & 0x7FF)[2:].zfill(11)  # Identifier A (11 bits)
        identifier_b = bin(frame_id & 0x3FFFF)[2:].zfill(18)        # Identifier B (18 bits)
        sof = "0"                                                   # Start-of-frame (SOF): Dominant
        srr = "1"                                                   # Substitute remote request (SRR): Recessive for extended frames
        ide = "1"                                                   # Identifier extension bit (IDE): Recessive for extended frames
        rtr = "0"                                                   # Remote transmission request (RTR): Dominant for data frames
        reserved_bits = "00"                                        # Reserved bits (r1, r0): Set to dominant

        dlc_bin = bin(dlc)[2:].zfill(4)

        data_field = "".join(bin(int(byte, 16))[2:].zfill(8) for byte in data_bytes)

        frame = f"{sof}{identifier_a}{srr}{ide}{identifier_b}{rtr}{reserved_bits}{dlc_bin}{data_field}"

        crc = calculate_crc(frame)

        frame_with_crc = frame + crc

        if is_last_frame:
            trailing_bits = "1" * 10  # CRC delimiter + ACK slot + ACK delimiter + EOF
        else:
            trailing_bits = "1" * 13  # CRC delimiter + ACK slot + ACK delimiter + EOF + IFS

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
    
def implement_error(frame, error_type, stuffed_positions):
    frame_bits = frame["stuffed_frame"]
    error_location = 0
    modified_frame = frame.copy()
    
    if error_type == "stuff":
        if not stuffed_positions:
            return frame  # No stuff bits to modify
    
        error_location = random.choice(stuffed_positions)
        modified_bits = list(frame_bits)
        modified_bits.pop(error_location)
        modified_frame["stuffed_frame"] = "".join(modified_bits)

    elif error_type == "form":
        possible_locations = [
            #0,                    # SOF
            len(frame_bits) - 13,  # CRC delimiter
            len(frame_bits) - 11,  # ACK delimiter
            len(frame_bits) - 10   # Start of EOF (7 bits)
        ]
        """
        SOF in possible_locations is commented out because it creates a problem with the CRC calucation.
        Meaning if the form error occurs in SOF position, then CRC will also be wrong, since SOF is a part of the CRC calucation. 
        """
        error_location = possible_locations[1] + random.randint(0, 8)
            
        modified_bits = list(frame_bits)
        modified_bits[error_location] = '0' if modified_bits[error_location] == '1' else '1'
        modified_frame["stuffed_frame"] = "".join(modified_bits)

    
    elif error_type == "crc":
        crc_start = len(frame_bits) - 28
        error_location = crc_start + random.randint(0, 14)
        modified_bits = list(frame_bits)
        modified_bits[error_location] = '0' if modified_bits[error_location] == '1' else '1'
        modified_frame["stuffed_frame"] = "".join(modified_bits)
    
    modified_frame["error_type"] = error_type
    modified_frame["error_location"] = error_location
    return modified_frame

def print_error(error_type, error_frame, frame, i):
    if error_type:
        print(f"Frame {i} with error:    {error_frame['stuffed_frame']}")
        print(f"Error:                 {' ' * error_frame['error_location']}^")
        print(f"Frame {i} without error: {frame['stuffed_frame']}\n")

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
    
    num_frames = yaml_data['frames']
    frames = []

    for i in range(1, num_frames + 1):
        frame_key = f'frame_{i}'
        frame_id = yaml_data[frame_key]['id']
        dlc = yaml_data[frame_key]['dlc']
        data = yaml_data[frame_key]['data']
        error_type = yaml_data[frame_key]['error']

        if frame_id < 2047:  # 2^11
            frame_type = "standard"
        elif frame_id > 2047 and frame_id < 536870911:  # 2^29
            frame_type = "extended"
        else:
            print("ID is outside of range")
            return

        data_bytes = []
        for byte in data:
            data_bytes.append(f"{byte:02x}")

        manual_data = input("Do you want to input data manually? (y/n): ").strip().lower()
        if manual_data == "y":
            data_bytes = []
            for j in range(dlc):
                data_byte = int(input(f"Enter byte {j + 1} (in hex, e.g., 0x12): "), 16)
                data_bytes.append(data_byte)
        else:
            prev_bit = curr_bit

        is_last_frame = i == (num_frames - 1)
        frame = generate_can_frame(frame_id, frame_type, dlc, data_bytes, is_last_frame)

def generate_can_frame(frame_id, frame_type, dlc, data_bytes, is_last_frame=False):
    if frame_type == "standard":
        identifier = bin(frame_id)[2:].zfill(11) # Identifier (11 bits)
        sof = "0"                                # Start-of-frame (SOF): Dominant
        rtr = "0"                                # Remote transmission request (RTR): Dominant for data frames
        ide = "0"                                # Identifier extension bit (IDE): Dominant for standard frames
        reserved_bit = "0"                       # Reserved bit (r0): Set to dominant

        data_name = '_'.join(x[2:] for x in frame['data'])

    save_to_csv(frames, f"{data_name}_with_bit_stuffing.csv", f"{data_name}_without_bit_stuffing.csv")

def save_to_csv(frames, filename_with, filename_without):
    with open(filename_with, mode="w", newline="") as file_with, open(filename_without, mode="w", newline="") as file_without:
        writer_with = csv.writer(file_with)
        
        for frame in frames:
            for bit in frame["stuffed_frame"]:
                writer_with.writerow([bit])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="Path to the yaml config file")
    args = parser.parse_args()

    if not args.path:
        print("Wrong or no path specified. Please specifiy a path to the yaml config file using '-p' or '--path'. For more information refer to '--help'")
        return

    with open(args.path) as stream:
        yaml_data = yaml.safe_load(stream)
    
    num_frames = yaml_data['frames']
    frames = []

    for i in range(1, num_frames + 1):
        frame_key = f'frame_{i}'
        frame_id = yaml_data[frame_key]['id']
        dlc = yaml_data[frame_key]['dlc']
        data = yaml_data[frame_key]['data']

        if frame_id < 2047:  # 2^11
            frame_type = "standard"
        elif frame_id > 2047 and frame_id < 536870911:  # 2^29
            frame_type = "extended"
        else:
            print("ID is outside of range")
            return

        data_bytes = []
        for byte in data:
            data_bytes.append(f"{byte:02x}")

        is_last_frame = i == num_frames
        frame = generate_can_frame(frame_id, frame_type, dlc, data_bytes, is_last_frame)

        print(f"\nFrame {i}:")
        print(f"Number of stuffed bits: {frame['stuffed_bits_count']}")
        print(f"ID (hex): {frame['id_hex']}")
        print(f"ID (bin): {frame['id_bin']}")
        print(f"DLC: {frame['dlc']}")
        print(f"Data: {frame['data']}")
        print(f"CRC (bin): {frame['crc_bin']}")
        print(f"CRC (hex): {frame['crc_hex']}\n")

    base_name = os.path.splitext(os.path.basename(args.path))[0]
    save_to_csv(frames, f"{base_name}.csv")

if __name__ == "__main__":
    main()