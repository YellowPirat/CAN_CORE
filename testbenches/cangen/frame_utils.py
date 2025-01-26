import csv

def calculate_crc(frame):
    polynomial = 0b1100010110011001  # CRC-15-CAN polynomial: x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
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

def save_to_csv(frames, filename_with):
    with open(filename_with, mode="w", newline="") as file:
        writer = csv.writer(file)
        
        for frame in frames:
            for bit in frame["stuffed_frame"]:
                writer.writerow([bit])

def print_frame_details(frame_number, bus_idle, frame_type, frame_without_error, frame_with_error, error_type, error_flag_length):
        print(f"\nFrame {frame_number}:")
        print(f"Bus idle length: {bus_idle}")
        print(f"Error type: {error_type}")
        print(f"Frame type: {frame_type}")
        print(f"Number of stuffed bits: {frame_without_error['stuffed_bits_count']}")
        print(f"ID (hex): {frame_without_error['id_hex']}")
        print(f"ID (bin): {frame_without_error['id_bin']}")
        print(f"DLC: {frame_without_error['dlc']}")
        if frame_type == "data":
            print(f"Data: {frame_without_error['data']}")
        print(f"CRC (hex): {frame_without_error['crc_hex']}")
        print(f"CRC (bin): {frame_without_error['crc_bin']}")
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
            print(f"Frame {frame_number} without error: {frame_without_error['stuffed_frame']}")