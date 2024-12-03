from dataclasses import dataclass
from typing import List

@dataclass
class CANFrame:
    def __init__(self):
        # Extended CAN Frame 
        self.sof: int = 0           # Start of Frame (1 bit)
        self.identifier_A: int = 0  # First part of the ID (11 bits)
        self.srr: int = 1           # Substitute remote request (1 bit)
        self.ide: int = 1           # Identifier extension bit (1 bit)
        self.identifier_B: int = 0  # Second part of the ID (18 bits)
        self.rtr: int = 0           # Remote Transmission Request (1 bit)
        self.r1: int = 0            # Reserved bit (1 bit)
        self.r0: int = 0            # Reserved bit (1 bit)
        self.dlc: int = 0           # Data Length Code (4 bits)
        self.data: List[int] = []   # Data Field (0-8 bytes)
        self.crc: int = 0           # CRC Field (15 bits)
        self.crc_delimiter: int = 1 # CRC Delimiter (1 bit)
        self.ack_slot: int = 1      # ACK Slot (1 bit)
        self.ack_delimiter: int = 1 # ACK Delimiter (1 bit)
        self.eof: int = 0x7F        # End of Frame (7 bits)
        self.ifs: int = 1           # Inter-frame spacing (3 bits)

    def set_identifier(self, identifier: int):
        if identifier > 0x1FFFFFFF:  # Check if value exceeds 29 bits
            raise ValueError("Identifier cannot exceed 29 bits (0x1FFFFFFF)")
        self.identifier_A = (identifier >> 18) & 0x7FF  # Most significant 11 bits
        self.identifier_B = identifier & 0x3FFFF        # Least significant 18 bits
        #print(f"Full ID: {bin(identifier)[2:].zfill(29)}")
        #print(f"ID_A: {bin(self.identifier_A)[2:].zfill(11)}")
        #print(f"ID_B: {bin(self.identifier_B)[2:].zfill(18)}")

    def calculate_crc15(self, bits: List[int]) -> int:
        # CAN uses CRC-15-CAN polynomial: x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
        CRC15_POLY = 0x4599
        crc = 0
        
        for bit in bits:
            crc_msb = (crc >> 14) & 1
            crc = ((crc << 1) | bit) & 0x7FFF
            if crc_msb:
                crc ^= CRC15_POLY

        #print(crc)
        return crc

    def generate_frame_bits(self) -> List[int]:
        bits = []
        
        # SOF (1 bit)
        bits.append(0) # Always dominant
        
        # Identifier_A (11 bits)
        id_A_bits = format(self.identifier_A, '011b')
        bits.extend([int(x) for x in id_A_bits])

        # SRR (1 bit)
        bits.append(self.srr) # Must be recessive for extended frame
        
        # IDE (1 bit)
        bits.append(self.ide) # Must be recessive for extended frame

        # Identifier_B (18 bits)
        id_B_bits = format(self.identifier_B, '018b')
        bits.extend([int(x) for x in id_B_bits])

        # RTR (1 bit)
        bits.append(self.rtr) # Must be dominant for data frames
        
        # r1 (1 bit)
        bits.append(self.r1) # Can be both but set as dominant

        # r0 (1 bit)
        bits.append(self.r0) # Can be both but set as dominant
        
        # DLC (4 bits)
        dlc_bits = format(self.dlc, '04b')
        bits.extend([int(x) for x in dlc_bits])
        
        # Data Field (<=64 bits)
        for byte in self.data:
            bits.extend([int(x) for x in format(byte, '08b')])
        
        # Calculate CRC for all bits up to this point
        crc_calc_bits = bits.copy()
        self.crc = self.calculate_crc15(crc_calc_bits)
        
        # CRC Field (15 bits)
        crc_bits = format(self.crc, '015b')
        bits.extend([int(x) for x in crc_bits])
        
        # CRC Delimiter (1 bit)
        bits.append(self.crc_delimiter) # Must be recessive
        
        # ACK Slot (1 bit)
        bits.append(self.ack_slot)
        
        # ACK Delimiter (1 bit)
        bits.append(self.ack_delimiter) # Must be recessive
        
        # EOF (7 bits)
        bits.extend([1] * 7) # Must be recessive

        # IFS (3 bits)
        #bits.extend([1] * 3) # Must be recessive
        # TODO: implement additional frames

        #print("Bits before stuffing:", "".join(str(b) for b in bits))
        
        return bits

def write_can_frame_to_file(filename: str, frame: CANFrame):
    with open(filename, 'w') as f:
        bits = frame.generate_frame_bits()
        bit_stuffing_counter = 0
        previous_bit = bits[0]
        
        for i in range(len(bits) - 10):  # CRC delimiter, ACK, ACK delimiter, EOF -> all recessive
            current_bit = bits[i]
            f.write(f"{current_bit}\n")
            
            if current_bit == previous_bit:
                bit_stuffing_counter += 1
                if bit_stuffing_counter == 5:
                    f.write(f"{1 if current_bit == 0 else 0}\n")
                    bit_stuffing_counter = 0
            else:
                bit_stuffing_counter = 1
            
            previous_bit = current_bit

        # Write the last 10 bits without stuffing
        for i in range(len(bits) - 10, len(bits) - 1):
            f.write(f"{bits[i]}\n")
        f.write(f"{bits[-1]}")

if __name__ == "__main__":
    frame = CANFrame()
    
    frame.set_identifier(0x123)          # 29-bit identifier
    frame.rtr = 0                           # Data frame
    frame.ide = 0                           # Extended frame
    frame.r1 = 0                            # Reserved
    frame.r0 = 0                            # Reserved
    frame.dlc = 4                           # 4 bytes of data
    frame.data = [0xDE, 0xAD, 0xAF, 0xFE]   # Data
    
    write_can_frame_to_file("extended_can_frame.csv", frame)