library ieee;
use ieee.std_logic_1164.all;
 
entity de1_sampling is
    port(
        -- ADC
        ADC_CS_n : out std_logic;
        ADC_DIN  : out std_logic;
        ADC_DOUT : in  std_logic;
        ADC_SCLK : out std_logic;
      
        -- Audio
        AUD_ADCDAT  : in    std_logic;
        AUD_ADCLRCK : inout std_logic;
        AUD_BCLK    : inout std_logic;
        AUD_DACDAT  : out   std_logic;
        AUD_DACLRCK : inout std_logic;
        AUD_XCK     : out   std_logic;
      
        -- CLOCK
        CLOCK_50  : in std_logic;
        CLOCK2_50 : in std_logic;
        CLOCK3_50 : in std_logic;
        CLOCK4_50 : in std_logic;
      
        -- SDRAM
        DRAM_ADDR  : out   std_logic_vector(12 downto 0);
        DRAM_BA    : out   std_logic_vector(1 downto 0);
        DRAM_CAS_N : out   std_logic;
        DRAM_CKE   : out   std_logic;
        DRAM_CLK   : out   std_logic;
        DRAM_CS_N  : out   std_logic;
        DRAM_DQ    : inout std_logic_vector(15 downto 0);
        DRAM_LDQM  : out   std_logic;
        DRAM_RAS_N : out   std_logic;
        DRAM_UDQM  : out   std_logic;
        DRAM_WE_N  : out   std_logic;
      
        -- I2C for Audio and Video-In
        FPGA_I2C_SCLK : out   std_logic;
        FPGA_I2C_SDAT : inout std_logic;
      
        -- SEG7
        HEX0_N : out std_logic_vector(6 downto 0);
        HEX1_N : out std_logic_vector(6 downto 0);
        HEX2_N : out std_logic_vector(6 downto 0);
        HEX3_N : out std_logic_vector(6 downto 0);
        HEX4_N : out std_logic_vector(6 downto 0);
        HEX5_N : out std_logic_vector(6 downto 0);
      
        -- IR
        IRDA_RXD : in  std_logic;
        IRDA_TXD : out std_logic;
      
        -- KEY_N
        KEY_N : in std_logic_vector(3 downto 0);
      
        -- LED
        LEDR : out std_logic_vector(9 downto 0);
      
        -- PS2
        PS2_CLK  : inout std_logic;
        PS2_CLK2 : inout std_logic;
        PS2_DAT  : inout std_logic;
        PS2_DAT2 : inout std_logic;
      
        -- SW
        SW : in std_logic_vector(9 downto 0);
      
        -- Video-In
        TD_CLK27   : inout std_logic;
        TD_DATA    : out   std_logic_vector(7 downto 0);
        TD_HS      : out   std_logic;
        TD_RESET_N : out   std_logic;
        TD_VS      : out   std_logic;
      
        -- VGA
        VGA_B       : out std_logic_vector(7 downto 0);
        VGA_BLANK_N : out std_logic;
        VGA_CLK     : out std_logic;
        VGA_G       : out std_logic_vector(7 downto 0);
        VGA_HS      : out std_logic;
        VGA_R       : out std_logic_vector(7 downto 0);
        VGA_SYNC_N  : out std_logic;
        VGA_VS      : out std_logic;
      
        -- GPIO_0
        GPIO_0 : inout std_logic_vector(35 downto 0);
      
        -- GPIO_1
        GPIO_1 : inout std_logic_vector(35 downto 0)
          );         
end de1_sampling;
 
architecture rtl of de1_sampling is

begin

	GPIO_0(0) <= '1';

end rtl;