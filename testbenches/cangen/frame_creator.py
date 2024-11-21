from dataclasses import dataclass
from typing import List

@dataclass
class CANFrame:
    def __init__(self):
        # Standard CAN Frame Fields (108 bits total)
        self.sof: int = 0          # Start of Frame (1 bit)
        self.identifier: int = 0   # 11 bits for standard frame
        self.rtr: int = 0          # Remote Transmission Request (1 bit)
        self.ide: int = 0          # Identifier Extension (1 bit)
        self.r0: int = 0           # Reserved bit (1 bit)
        self.dlc: int = 0          # Data Length Code (4 bits)
        self.data: List[int] = []  # Data Field (0-8 bytes = 64 bits max)
        self.crc: int = 0          # CRC Field (15 bits)
        self.crc_delimiter: int = 1 # CRC Delimiter (1 bit)
        self.ack_slot: int = 1     # ACK Slot (1 bit)
        self.ack_delimiter: int = 1 # ACK Delimiter (1 bit)
        self.eof: int = 0x7F       # End of Frame (7 bits)

    def calculate_crc15(self, bits: List[int]) -> int:
        # CAN uses CRC-15-CAN polynomial: x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
        CRC15_POLY = 0x4599
        crc = 0
        
        for bit in bits:
            crc_msb = (crc >> 14) & 1
            crc = ((crc << 1) | bit) & 0x7FFF
            if crc_msb:
                crc ^= CRC15_POLY

        return crc

    def generate_frame_bits(self) -> List[int]:
        bits = []
        
        # SOF (1 bit)
        bits.append(0)  # Always dominant
        
        # Identifier (11 bits)
        id_bits = format(self.identifier, '011b')
        bits.extend([int(x) for x in id_bits])
        
        # RTR (1 bit)
        bits.append(self.rtr)
        
        # IDE (1 bit)
        bits.append(self.ide)
        
        # r0 (1 bit)
        bits.append(self.r0)
        
        # DLC (4 bits)
        dlc_bits = format(self.dlc, '04b')
        bits.extend([int(x) for x in dlc_bits])
        
        # Data Field (64 bits)
        for byte in self.data:
            bits.extend([int(x) for x in format(byte, '08b')])
        # Pad with zeros if less than 8 bytes
        #while len(bits) < ((self.dlc * 8) - 1):  # 19 control bits + 64 data bits
        #    bits.append(0)
        
        # Calculate CRC for all bits up to this point
        crc_calc_bits = bits.copy()
        self.crc = self.calculate_crc15(crc_calc_bits)
        
        # CRC Field (15 bits)
        crc_bits = format(self.crc, '015b')
        bits.extend([int(x) for x in crc_bits])
        
        # CRC Delimiter (1 bit)
        bits.append(self.crc_delimiter)
        
        # ACK Slot (1 bit)
        bits.append(self.ack_slot)
        
        # ACK Delimiter (1 bit)
        bits.append(self.ack_delimiter)
        
        # EOF (7 bits)
        bits.extend([1] * 7)
        
        return bits

def write_can_frame_to_file(filename: str, frame: CANFrame):
    with open(filename, 'w') as f:
        bits = frame.generate_frame_bits()
        bit_stuffing_counter = 0
        previous_bit = bits[0]
        for i in range(len(bits) - 10): # CRC delimiter, ACK, ACK delimiter, EOF -> all recessive
            current_bit = bits[i]

            if bit_stuffing_counter == 4:
                f.write(f"{1 if previous_bit == 0 else 0}\n")
                bit_stuffing_counter = 0
                
            
            f.write(f"{current_bit}\n")

            if current_bit == previous_bit:
                bit_stuffing_counter += 1
            else:
                bit_stuffing_counter = 0
            
            previous_bit = current_bit

        for i in range(len(bits) - 10, len(bits) - 1):
            f.write(f"{bits[i]}\n")
        f.write(f"{bits[-1]}")

if __name__ == "__main__":
    frame = CANFrame()
    
    frame.identifier = 0x123       # 11-bit identifier
    frame.rtr = 0                  # Data frame
    frame.ide = 0                  # Standard frame
    frame.r0 = 0                  
    frame.dlc = 6                  # 8 bytes of data
    frame.data = [0xDE, 0xAD, 0xBE, 0xEF, 0xAF, 0xFE]
    
    write_can_frame_to_file("standard_can_frame.csv", frame)