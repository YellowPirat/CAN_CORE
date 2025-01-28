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