from dataclasses import dataclass
from typing import List

@dataclass
class CANFrame:
    def __init__(self):
        # Standard CAN Frame Fields (108 bits total)
        self.sof: int = 0          # Start of Frame (1 bit)
        self.identifier: int = 0    # 11 bits for standard frame
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
        while len(bits) < 83:  # 19 control bits + 64 data bits
            bits.append(0)
        
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
    # Change extension to .csv
    if not filename.endswith('.csv'):
        filename = filename.replace('.txt', '.csv')
        if not filename.endswith('.csv'):
            filename += '.csv'
            
    with open(filename, 'w') as f:
        bits = frame.generate_frame_bits()
        # Write each bit as a row in CSV format
        for bit in bits:
            f.write(f"{bit}\n")

if __name__ == "__main__":
    frame = CANFrame()
    
    frame.identifier = 0x123       # 11-bit identifier
    frame.rtr = 0                  # Data frame
    frame.ide = 0                  # Standard frame
    frame.r0 = 0                  
    frame.dlc = 8                  # 8 bytes of data
    frame.data = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]
    
    write_can_frame_to_file("can_frame.csv", frame)