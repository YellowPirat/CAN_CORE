library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_lite_intf.all;

entity axi_smmmm is
    generic (
        slave_count_g           : natural   := 1;
        start_addr_g            : unsigned(20 downto 0);
        offset_addr_g           : unsigned(20 downto 0)
    );
    port(
        clk                     : in    std_logic                                       := '0';
        rst_n                   : in    std_logic                                       := '1';

        -- MASTER
        m_axi_awaddr            : in    std_logic_vector(20 downto 0)                   := (others => '0');
        m_axi_awvalid           : in    std_logic                                       := '0';
        m_axi_awready           : out   std_logic                                       := '0';
    
        m_axi_wdata             : in    std_logic_vector(31 downto 0)                   := (others => '0');
        m_axi_wvalid            : in    std_logic                                       := '0';
        m_axi_wready            : out   std_logic                                       := '0';
    
        m_axi_bresp             : out   std_logic_vector(1 downto 0)                    := (others => '0');
        m_axi_bvalid            : out   std_logic                                       := '0';
        m_axi_bready            : in    std_logic                                       := '0';
    
        m_axi_araddr            : in    std_logic_vector(20 downto 0)                   := (others => '0');
        m_axi_arvalid           : in    std_logic                                       := '0';
        m_axi_arready           : out   std_logic                                       := '0';
    
        m_axi_rdata             : out   std_logic_vector(31 downto 0)                   := (others => '0');
        m_axi_rresp             : out   std_logic_vector(1 downto 0)                    := (others => '0');
        m_axi_rvalid            : out   std_logic                                       := '0';
        m_axi_rready            : in    std_logic                                       := '0';

        -- SLAVE
        s_axi_awaddr            : out   axi_addr_vec_t(slave_count_g - 1 downto 0)      := (others => (others => '0'));
        s_axi_awvalid           : out   axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');
        s_axi_awready           : in    axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');

        s_axi_wdata             : out   axi_data_vec_t(slave_count_g - 1 downto 0)      := (others => (others => '0'));
        s_axi_wvalid            : out   axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');
        s_axi_wready            : in    axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');

        s_axi_bresp             : in    axi_resp_vec_t(slave_count_g - 1 downto 0)      := (others => (others => '0'));
        s_axi_bvalid            : in    axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');
        s_axi_bready            : out   axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');

        s_axi_araddr            : out   axi_addr_vec_t(slave_count_g - 1 downto 0)      := (others => (others => '0'));
        s_axi_arvalid           : out   axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');
        s_axi_arready           : in    axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');

        s_axi_rdata             : in    axi_data_vec_t(slave_count_g - 1 downto 0)      := (others => (others => '0'));
        s_axi_rresp             : in    axi_resp_vec_t(slave_count_g - 1 downto 0)      := (others => (others => '0'));
        s_axi_rvalid            : in    axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0');
        s_axi_rready            : out   axi_sig_vec_t(slave_count_g - 1 downto 0)       := (others => '0')
    );
end axi_smmmm;

architecture rtl of axi_smmmm is

    signal slave_sel    : integer range 0 to slave_count_g      := 0;

    -- 1 := read     0 := write
    signal rorw         : std_logic                             := '1';

    type state_t is(
        write_s,
        read_s
    );
    signal current_state, new_state : state_t                   := read_s;


begin

    rorw_p : process(current_state, m_axi_awvalid, m_axi_arvalid)
    begin 
        new_state           <= current_state;
        rorw                <= '0';

        case current_state is
            when write_s =>
                if m_axi_arvalid = '1' and m_axi_awvalid = '0' then
                    new_state           <= read_s;
                    rorw                <= '1';
                else
                    rorw                <= '0';
                end if;
                
            when read_s =>
                if m_axi_arvalid = '0' and m_axi_awvalid = '1' then
                    new_state           <= write_s;
                    rorw                <= '0';
                else
                    rorw                <= '1';
                end if;


            when others => new_state <= write_s;
            
        end case;
    end process;

    p : process(clk) 
    begin
        if rising_edge(clk) then
            current_state           <= new_state;

            if rst_n = '0' then
                current_state       <= write_s;
            end if;
        end if;
    end process p;

    address_decode : process(m_axi_awaddr, m_axi_araddr, rorw)
    begin
        for i in 0 to slave_count_g - 1 loop
            
            if rorw = '0' then
                if unsigned(m_axi_awaddr) >=  start_addr_g + i * offset_addr_g and unsigned(m_axi_awaddr) <= start_addr_g + i * offset_addr_g + offset_addr_g then
                    slave_sel <= i;
                end if;
            end if;
            
            if rorw = '1' then
                if unsigned(m_axi_araddr) >=  start_addr_g + i * offset_addr_g and unsigned(m_axi_araddr) <= start_addr_g + i * offset_addr_g + offset_addr_g then
                    slave_sel <= i;
                end if;
            end if;
        end loop;
    end process;

    in_out_gen : for i in 0  to slave_count_g - 1 generate 
        s_axi_awaddr(i)     <= m_axi_awaddr     when slave_sel = i else (others => '0');
        s_axi_awvalid(i)    <= m_axi_awvalid    when slave_sel = i else '0';
        s_axi_wdata(i)      <= m_axi_wdata      when slave_sel = i else (others => '0');
        s_axi_wvalid(i)     <= m_axi_wvalid     when slave_sel = i else '0';
        s_axi_bready(i)     <= m_axi_bready     when slave_sel = i else '0';
        s_axi_araddr(i)     <= m_axi_araddr     when slave_sel = i else (others => '0');
        s_axi_arvalid(i)    <= m_axi_arvalid    when slave_sel = i else '0';
        s_axi_rready(i)     <= m_axi_rready     when slave_sel = i else '0';
    end generate in_out_gen;

    m_axi_awready   <= s_axi_awready(slave_sel);
    m_axi_wready    <= s_axi_wready(slave_sel);
    m_axi_bresp     <= s_axi_bresp(slave_sel);
    m_axi_bvalid    <= s_axi_bvalid(slave_sel);
    m_axi_arready   <= s_axi_arready(slave_sel);
    m_axi_rdata     <= s_axi_rdata(slave_sel);
    m_axi_rresp     <= s_axi_rresp(slave_sel);
    m_axi_rvalid    <= s_axi_rvalid(slave_sel);


end rtl;