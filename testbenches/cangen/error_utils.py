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