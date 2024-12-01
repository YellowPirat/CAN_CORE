import random
import csv

def calculate_crc(frame):
    """
    Calculate the CRC for the given CAN frame using the polynomial:
    x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
    """
    polynomial = 0b1100010110011001  # Generator polynomial
    crc = 0
    for bit in frame:
        crc <<= 1
        if int(bit) ^ (crc >> 15):  # XOR with MSB
            crc ^= polynomial
        crc &= 0x7FFF
    return bin(crc)[2:].zfill(15)

def apply_bit_stuffing(frame):
    stuffed_frame = []
    same_bit_count = 1
    bits_stuffed = 0

    for i in range(1, len(frame)):
        stuffed_frame.append(frame[i - 1])
        if frame[i] == frame[i - 1]:
            same_bit_count += 1
            if same_bit_count == 6:
                stuffed_frame.append("1" if frame[i] == "0" else "0")
                bits_stuffed += 1
                same_bit_count = 1
        else:
            same_bit_count = 1
    stuffed_frame.append(frame[-1])
    print(f"Number of bits stuffed: {bits_stuffed}")
    return "".join(stuffed_frame)

def generate_can_frame(frame_id, dlc, data_bytes, is_last_frame=False):
    """
    Generate a single complete CAN extended frame, including all fields.
    """
    identifier_a = bin((frame_id >> 18) & 0x7FF)[2:].zfill(11)  # Identifier A (11 bits)
    identifier_b = bin(frame_id & 0x3FFFF)[2:].zfill(18)        # Identifier B (18 bits)

    sof = "0"                   # Start-of-frame (SOF): Dominant
    srr = "1"                   # Substitute remote request (SRR): Recessive for extended frames
    ide = "1"                   # Identifier extension bit (IDE): Recessive for extended frames
    rtr = "0"                   # Remote transmission request (RTR): Dominant for data frames
    reserved_bits = "00"        # Reserved bits (r1, r0): Set to dominant

    dlc_bin = bin(dlc)[2:].zfill(4)

    data_field = "".join(bin(byte)[2:].zfill(8) for byte in data_bytes)

    frame = f"{sof}{identifier_a}{srr}{ide}{identifier_b}{rtr}{reserved_bits}{dlc_bin}{data_field}"

    crc = calculate_crc(frame)

    frame_with_crc = frame + crc

    if is_last_frame:
        trailing_bits = "1" * 10  # CRC delimiter + ACK slot + ACK delimiter + EOF
    else:
        trailing_bits = "1" * 13  # CRC delimiter + ACK slot + ACK delimiter + EOF + IFS

    stuffed_frame = apply_bit_stuffing(frame_with_crc)

    return {
        "id_hex": hex(frame_id),
        "id_bin": f"{identifier_a}_{identifier_b}",
        "dlc": dlc,
        "data": [hex(byte) for byte in data_bytes],
        "crc_bin": crc,
        "crc_hex": hex(int(crc, 2)),
        "unstuffed_frame": frame_with_crc + trailing_bits,
        "stuffed_frame": stuffed_frame + trailing_bits,
    }

def main():
    num_frames = int(input("How many CAN frames would you like to generate? "))

    frames = []
    for i in range(num_frames):
        print(f"\nFrame {i + 1}:")
        
        dlc = int(input(f"Enter DLC (0-8) for Frame {i + 1}: "))

        manual_data = input("Do you want to input data manually? (yes/no): ").strip().lower()
        if manual_data == "yes":
            data_bytes = []
            for j in range(dlc):
                data_byte = int(input(f"Enter byte {j + 1} (in hex, e.g., 0x12): "), 16)
                data_bytes.append(data_byte)
        else:
            data_bytes = [random.randint(0, 255) for _ in range(dlc)]

        frame_id = random.randint(0, (1 << 29) - 1)
        is_last_frame = i == (num_frames - 1)
        frame = generate_can_frame(frame_id, dlc, data_bytes, is_last_frame)
        frames.append(frame)

        print(f"ID (hex): {frame['id_hex']}")
        print(f"ID (bin): {frame['id_bin']}")
        print(f"DLC: {frame['dlc']}")
        print(f"Data: {frame['data']}")
        print(f"CRC (bin): {frame['crc_bin']}")
        print(f"CRC (hex): {frame['crc_hex']}")

    save_to_csv(frames, "with_bit_stuffing.csv", "without_bit_stuffing.csv")

def save_to_csv(frames, filename_with, filename_without):
    """
    Save frames to CSV files: one with bit stuffing and one without.
    Each bit is written on a separate line.
    """
    with open(filename_with, mode="w", newline="") as file_with, open(filename_without, mode="w", newline="") as file_without:
        writer_with = csv.writer(file_with)
        writer_without = csv.writer(file_without)
        
        for frame in frames:
            for bit in frame["stuffed_frame"]:
                writer_with.writerow([bit])

            for bit in frame["unstuffed_frame"]:
                writer_without.writerow([bit])

if __name__ == "__main__":
    main()