import random
from frame_utils import apply_bit_stuffing, calculate_crc

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
            "crc_hex": hex(int(crc, 2)),
            "crc_bin": crc,
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
            "crc_hex": hex(int(crc, 2)),
            "crc_bin": crc,
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
            "crc_hex": hex(int(crc, 2)),
            "crc_bin": crc,
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
            "crc_hex": hex(int(crc, 2)),
            "crc_bin": crc,
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