from dataclasses import dataclass
from typing import List

@dataclass
class PeripheralStatus:  # Baseaddress: 0x00
    def __init__(self):
        self.buffer_usage: int = 0          # bits 0-9: usage of the output fifo buffer
        self.peripheral_error: int = 0       # bits 10-14: 5 bits indicate error states in the cancore periphery
        self.core_active: int = 0           # bit 15: indicates whether the cancore is active or not
        self.missed_frames: int = 0         # bits 16-30: 15 bits show how many can frames are lost
        self.missed_frames_overflow: int = 0 # bit 31: indicates whether the missed_frames counter has overflow

    def to_bits(self) -> List[int]:
        bits = []
        bits.extend([int(x) for x in format(self.buffer_usage, '010b')])         # 10 bits (0-9)
        bits.extend([int(x) for x in format(self.peripheral_error, '05b')])      # 5 bits (10-14)
        bits.extend([self.core_active])                                          # 1 bit (15)
        bits.extend([int(x) for x in format(self.missed_frames, '015b')])        # 15 bits (16-30)
        bits.extend([self.missed_frames_overflow])                               # 1 bit (31)
        return bits

@dataclass
class Word0:  # Baseaddress: 0x04
    def __init__(self):
        self.error_codes: int = 0    # bits 0-9: 10 bits indicate various error cases during reception
        self.frame_type: int = 0     # bits 10-11: 2 bits can indicate CAN-2.0, CAN FD or newer versions like CAN XL
        self.timestamp: int = 0      # bits 12-31: first 20 bits of the 48 bit timestamp

    def to_bits(self) -> List[int]:
        bits = []
        bits.extend([int(x) for x in format(self.error_codes, '010b')])  # 10 bits (0-9)
        bits.extend([int(x) for x in format(self.frame_type, '02b')])    # 2 bits (10-11)
        bits.extend([int(x) for x in format(self.timestamp, '020b')])    # 20 bits (12-31)
        return bits

@dataclass
class Word1:  # Baseaddress: 0x08
    def __init__(self):
        self.timestamp: int = 0    # bits 0-27: last 28 bits of the 48 bit timestamp
        self.can_dlc: int = 0      # bits 28-31: these 4 bits show how many bytes are in the payload

    def to_bits(self) -> List[int]:
        bits = []
        bits.extend([int(x) for x in format(self.timestamp, '028b')])  # 28 bits (0-27)
        bits.extend([int(x) for x in format(self.can_dlc, '04b')])    # 4 bits (28-31)
        return bits

@dataclass
class Word2:  # Baseaddress: 0x0C
    def __init__(self):
        self.can_id: int = 0     # bits 0-28: contains the id of the received canframe
        self.rtr: int = 0        # bit 29: retransmition request flag
        self.eff: int = 0        # bit 30: extended frame format id
        self.err: int = 0        # bit 31: error flag

    def to_bits(self) -> List[int]:
        bits = []
        bits.extend([int(x) for x in format(self.can_id, '029b')])  # 29 bits (0-28)
        bits.extend([self.rtr])                                     # 1 bit (29)
        bits.extend([self.eff])                                     # 1 bit (30)
        bits.extend([self.err])                                     # 1 bit (31)
        return bits

@dataclass
class Word3:  # Baseaddress: 0x10
    def __init__(self):
        self.crc: int = 0            # bits 0-14: cyclic redundancy check
        self.crc_delimiter: int = 1   # bit 15
        self.not_used: int = 0       # bits 16-31: addressspace is not used

    def to_bits(self) -> List[int]:
        bits = []
        bits.extend([int(x) for x in format(self.crc, '015b')])    # 15 bits (0-14)
        bits.extend([self.crc_delimiter])                          # 1 bit (15)
        bits.extend([0] * 16)                                      # 16 bits not used (16-31)
        return bits

@dataclass
class Word4:  # Baseaddress: 0x14
    def __init__(self):
        self.data: List[int] = [0] * 4  # bits 0-31: first 4 bytes of data

    def to_bits(self) -> List[int]:
        bits = []
        for byte in self.data:
            bits.extend([int(x) for x in format(byte, '08b')])
        return bits

@dataclass
class Word5:  # Baseaddress: 0x18
    def __init__(self):
        self.data: List[int] = [0] * 4  # bits 32-63: last 4 bytes of data

    def to_bits(self) -> List[int]:
        bits = []
        for byte in self.data:
            bits.extend([int(x) for x in format(byte, '08b')])
        return bits

def calculate_crc15(data_bits: List[int]) -> int:
    # CAN uses CRC-15-CAN polynomial: x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
    CRC15_POLY = 0x4599
    
    # Initialize CRC register
    crc = 0
    
    # Calculate CRC
    for bit in data_bits:
        crc_msb = (crc >> 14) & 1
        crc = ((crc << 1) | bit) & 0x7FFF  # Keep 15 bits
        if crc_msb:
            crc ^= CRC15_POLY
            
    return crc

class CANFrame:
    def __init__(self):
        self.peripheral_status = PeripheralStatus()
        self.word0 = Word0()
        self.word1 = Word1()
        self.word2 = Word2()
        self.word3 = Word3()
        self.word4 = Word4()
        self.word5 = Word5()

    def calculate_frame_crc(self) -> int:
        # Collect bits that are part of CRC calculation
        crc_bits = []
        
        # Add ID bits
        id_bits = [int(x) for x in format(self.word2.can_id, '029b')]
        crc_bits.extend(id_bits)
        
        # Add control bits (RTR, EFF, DLC)
        crc_bits.append(self.word2.rtr)
        crc_bits.append(self.word2.eff)
        crc_bits.extend([int(x) for x in format(self.word1.can_dlc, '04b')])
        
        # Add data bits
        for byte in self.word4.data + self.word5.data:
            crc_bits.extend([int(x) for x in format(byte, '08b')])
            
        return calculate_crc15(crc_bits)

    def generate_frame_bits(self) -> List[int]:
        # Calculate CRC before generating bits
        self.word3.crc = self.calculate_frame_crc()
        
        all_bits = []
        all_bits.extend(self.peripheral_status.to_bits())
        all_bits.extend(self.word0.to_bits())
        all_bits.extend(self.word1.to_bits())
        all_bits.extend(self.word2.to_bits())
        all_bits.extend(self.word3.to_bits())
        all_bits.extend(self.word4.to_bits())
        all_bits.extend(self.word5.to_bits())
        return all_bits

def write_can_frame_to_file(filename: str, frame: CANFrame):
    with open(filename, 'w') as f:
        bits = frame.generate_frame_bits()
        for bit in bits:
            f.write(f"{bit}\n")

if __name__ == "__main__":
    # Example usage
    frame = CANFrame()
    
    # Configure Peripheral Status (Word at 0x00)
    frame.peripheral_status.buffer_usage = 0
    frame.peripheral_status.peripheral_error = 0
    frame.peripheral_status.core_active = 1
    frame.peripheral_status.missed_frames = 0
    frame.peripheral_status.missed_frames_overflow = 0
    
    # Configure Word0
    frame.word0.error_codes = 0
    frame.word0.frame_type = 0  # CAN 2.0
    frame.word0.timestamp = 0x12345  # First 20 bits
    
    # Configure Word1
    frame.word1.timestamp = 0x789ABC  # Last 28 bits
    frame.word1.can_dlc = 8  # 8 bytes of data
    
    # Configure Word2
    frame.word2.can_id = 0x123
    frame.word2.rtr = 0
    frame.word2.eff = 0
    frame.word2.err = 0
    
    # Configure Word4 (first 4 bytes of data)
    frame.word4.data = [0x11, 0x22, 0x33, 0x44]
    
    # Configure Word5 (last 4 bytes of data)
    frame.word5.data = [0x55, 0x66, 0x77, 0x88]
    
    # Write to file
    write_can_frame_to_file("can_frame.txt", frame)