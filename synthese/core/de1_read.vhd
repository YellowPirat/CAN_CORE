library ieee;
use ieee.std_logic_1164.all;
 
entity de1_read is
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
end de1_read;
 
architecture rtl of de1_read is

	signal dbg_led_s 					: std_logic_vector(5 downto 0);
	signal stb_s						: std_logic_vector(5 downto 0);
	signal rxd_s						: std_logic_vector(5 downto 0);
	signal txd_s						: std_logic_vector(5 downto 0);
	
    signal rxd_async_s              : std_logic;
    signal frame_finished_s         : std_logic;
    signal rxd_sync_s               : std_logic;
    signal sample_s                 : std_logic;
    signal stuff_bit_s              : std_logic;
    signal bus_active_detect_s      : std_logic;

    signal id_s                     : std_logic_vector(28 downto 0);
    signal rtr_s                    : std_logic;
    signal eff_s                    : std_logic;
    signal err_s                    : std_logic;
    signal dlc_s                    : std_logic_vector(3 downto 0);
    signal crc_s                    : std_logic_vector(14 downto 0);
    signal data_s                   : std_logic_vector(63 downto 0);
    signal data_valid_s             : std_logic;


    signal uart_rx_s                : std_logic;
    signal uart_tx_s                : std_logic;
    signal uart_data_s              : std_logic_vector(127 downto 0);

    signal reset_core_s             : std_logic;
    signal reset_destuffing_s       : std_logic;

    signal decode_error_s           : std_logic;
    signal stuff_error_s            : std_logic;

    signal enable_destuffing_s      : std_logic;
	
	signal rst_n					: std_logic;
    signal clk                      : std_logic;
	 
	 
	 
	 
	 
	 signal reload_s : std_logic;
	 signal edge_s : std_logic;

begin

    clk <= CLOCK_50;

	stb_s <= "000000";
	
	rst_sync_i0 : entity work.olo_base_cc_reset
		port map(
			A_Clk					=> CLOCK_50,
			A_RstIn				=> KEY_N(0),
			A_RstOut				=> rst_n,
			
			B_Clk					=> CLOCK_50,
			B_RstIn				=> KEY_N(0)
		);


	shield_adapter_i0 : entity work.shield_adapter
		port map(
			gpio_b						=> GPIO_0,
			dbg_led_i					=> dbg_led_s,
			stb_i							=> stb_s,
			rxd_o							=> rxd_s,
			txd_i							=> txd_s
		);

        rxd_async_s <= rxd_s(0);

		
	  sampling_i0 : entity work.de1_sampling
	  port map(
			clk                     => clk,
			rst_n                   => rst_n,

			rxd_i                   => rxd_async_s,
			frame_finished_i        => frame_finished_s,
			enable_destuffing_i     => enable_destuffing_s,
			reset_destuffing_i      => reset_destuffing_s,

			rxd_sync_o              => rxd_sync_s,
			sample_o                => sample_s,
			stuff_bit_o             => stuff_bit_s,
			bus_active_detect_o     => bus_active_detect_s,
			stuff_error_o           => stuff_error_s
	 );

    error_handling_i0 : entity work.de1_error_handling
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_i                   => rxd_sync_s,
            sample_i                => sample_s,

            stuff_error_i           => stuff_error_s,
            decode_error_i          => decode_error_s,
            sample_error_i          => '0',

            reset_core_o            => reset_core_s,
            reset_destuffing_o      => reset_destuffing_s
        );



    core_i0 : entity work.de1_core
    port map(
        clk                         => clk,
        rst_n                       => rst_n,

        rxd_sync_i                  => rxd_sync_s,
        sample_i                    => sample_s,
        stuff_bit_i                 => stuff_bit_s,
        bus_active_detect_i         => bus_active_detect_s,

        id_o                        => id_s,
        rtr_o                       => rtr_s,
        eff_o                       => eff_s,
        err_o                       => err_s,
        dlc_o                       => dlc_s,
        data_o                      => data_s,
        crc_o                       => crc_s,

        valid_o                     => data_valid_s,

        frame_finished_o            => frame_finished_s,

        reset_i                     => reset_core_s,
        decode_error_o              => decode_error_s,
        enable_destuffing_o         => enable_destuffing_s
    );
		 





	 

	 LEDR(0) <= reset_core_s;
	 LEDR(1) <= reset_destuffing_s;
	 
	 GPIO_1(2) <= rxd_sync_s;
	 GPIO_1(3) <= sample_s;
	 GPIO_1(4) <= stuff_bit_s;
	 GPIO_1(5) <= bus_active_detect_s;
	 GPIO_1(6) <= rst_n;
	 GPIO_1(7) <= edge_s;
	 
    -- ID
    uart_data_s(28 downto 0)        <= id_s;
    uart_data_s(31 downto 29)       <= (others => '0');
    -- FLAGS
    uart_data_s(32)                 <= rtr_s;
    uart_data_s(33)                 <= eff_s;
    uart_data_s(34)                 <= err_s;
    uart_data_s(39 downto 35)       <= (others => '0');
    -- DLC
    uart_data_s(43 downto 40)       <= dlc_s;
    uart_data_s(47 downto 44)       <= (others => '0');
    -- DATA
    uart_data_s(111 downto 48)      <= data_s;
    -- CRC
    uart_data_s(126 downto 112)     <= crc_s;
    uart_data_s(127)                <= '0';


    debug_i0 : entity work.de1_debug
        generic map(
            widght_g                => 128
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            data_i                  => uart_data_s,
            valid_i                 => data_valid_s,

            rxd_i                   => uart_rx_s,
            txd_o                   => uart_tx_s
        );

		  
		GPIO_1(0) <= uart_rx_s;
		GPIO_1(1) <= uart_tx_s;
		  

		
	bin2hex_i0 : entity work.bin2hex
		port map(
			bin_i				=> data_s(3 downto 0),
			hex_o				=> HEX0_N
		);
		
	bin2hex_i1 : entity work.bin2hex
		port map(
			bin_i				=> data_s(7 downto 4),
			hex_o				=> HEX1_N
		);
		
	bin2hex_i2 : entity work.bin2hex
		port map(
			bin_i				=> data_s(11 downto 8),
			hex_o				=> HEX2_N
		);
		
	bin2hex_i3 : entity work.bin2hex
		port map(
			bin_i				=> data_s(15 downto 12),
			hex_o				=> HEX3_N
		);
		
	bin2hex_i4 : entity work.bin2hex
		port map(
			bin_i				=> data_s(19 downto 16),
			hex_o				=> HEX4_N
		);
		
	bin2hex_i5 : entity work.bin2hex
		port map(
			bin_i				=> data_s(23 downto 20),
			hex_o				=> HEX5_N
		);

end rtl;