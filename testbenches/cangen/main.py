import yaml
import argparse
from frame_utils import save_to_csv
from error_utils import implement_error
from frame_generator import generate_data_frame, generate_error_frame, generate_remote_frame

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="Path to the YAML config file")
    args = parser.parse_args()

    if not args.path:
        print("Wrong or no path specified. Please specifiy a path to the YAML config file using '-p' or '--path'. For more information refer to '--help'")
        return

    with open(args.path) as stream:
        yaml_data = yaml.safe_load(stream)
    
    frames = []
    frame_number = 0

    start_idle = {"stuffed_frame": [1] * 64}
    frames.append(start_idle)
    
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
                if error_type == "crc": # The reason for specific handling of crc error is that the error flag starts at the bit following ACK delimiter
                    ack_delimiter = len(frame_with_error["stuffed_frame"]) - 11 - bus_idle
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:ack_delimiter+1]
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
                if error_type == "crc": # The reason for specific handling of crc error is that the error flag starts at the bit following ACK delimiter
                    ack_delimiter = len(frame_with_error["stuffed_frame"]) - 11 - bus_idle
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:ack_delimiter+1]
                    combined_frame = {"stuffed_frame": frame_before_error_flag + error_frame}
                else:
                    frame_before_error_flag = frame_with_error["stuffed_frame"][:error_locations+1]
                    combined_frame = {"stuffed_frame": frame_before_error_flag + error_frame}
                frames.append(combined_frame) # Frame with error frame
                frames.append(frame_without_error) # Same frame without error
            else: # Remote frame without errors
                frames.append(frame_without_error)

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

    print("")
    save_to_csv(frames, f"can_message.csv")

if __name__ == "__main__":
    main()