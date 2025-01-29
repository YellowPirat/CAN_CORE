import random
from frame_utils import apply_bit_stuffing

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
        crc_delimiter = eof_end - 3
        ack_delimiter = eof_end - 1

        possible_locations = [
            crc_delimiter,
            ack_delimiter,
            eof_error_location
        ]
        error_positions = random.choice(possible_locations)
        modified_bits = list(frame_bits)
        modified_bits[error_positions] = '0' if modified_bits[error_positions] == '1' else '1'
        modified_frame["stuffed_frame"] = "".join(modified_bits)

    elif error_type == "ack":
        ack_slot = len(frame_bits) - 12 - bus_idle
        error_positions = ack_slot
        modified_bits = list(frame_bits)
        modified_bits[error_positions] = '1'
        modified_frame["stuffed_frame"] = "".join(modified_bits)
    
    elif error_type == "crc":
        crc_start = len(frame_bits) - 28 - bus_idle
        stuff_bits_after = sum(1 for pos in stuffed_positions if pos >= crc_start) # The positon of the first bit of the CRC sequence needs to be adjusted by a number of stuffed bits after it
        crc_start += stuff_bits_after
        crc_end = crc_start + 15
        modified_bits = list(frame_bits)
        crc_sequence = []

        available_positions = [pos for pos in range(crc_start, crc_end) if pos not in stuffed_positions] # Available positions in CRC range, excluding stuffed positions
        error_positions = random.sample(available_positions, random.randint(1, len(available_positions)))
        crc_sequence = [modified_bits[pos] for pos in available_positions]

        for pos in error_positions:
            modified_bits[pos] = '1' if modified_bits[pos] == '0' else '0' # Flip the values of the selected bits
            idx = available_positions.index(pos)
            crc_sequence[idx] = '1' if crc_sequence[idx] == '0' else '0'
        
        bits_before_crc = crc_start - 4
        stuffed_frame, stuff_cnt, _ = apply_bit_stuffing(''.join(modified_bits[bits_before_crc:crc_end]))

        modified_frame["stuffed_frame"] = frame_bits[:bits_before_crc] + stuffed_frame + frame_bits[crc_end:]
        modified_frame["stuffed_bits_count"] = stuff_cnt
        modified_frame["crc_hex"] = hex(int(''.join(crc_sequence), 2))

    modified_frame["error_type"] = error_type
    modified_frame["error_locations"] = error_positions
    return modified_frame