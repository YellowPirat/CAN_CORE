  -- Address decoding process
  address_decode: process(m_axi_intf_s.axi_awaddr, m_axi_intf_s.axi_araddr)
  begin
    if (unsigned(m_axi_intf_s.axi_awaddr) >= unsigned(SLAVE1_BASE_ADDR_a) and 
        unsigned(m_axi_intf_s.axi_awaddr) <= unsigned(SLAVE1_HIGH_ADDR_a)) or
       (unsigned(m_axi_intf_s.axi_araddr) >= unsigned(SLAVE1_BASE_ADDR_a) and
        unsigned(m_axi_intf_s.axi_araddr) <= unsigned(SLAVE1_HIGH_ADDR_a)) then
      slave_sel <= 1;
    elsif (unsigned(m_axi_intf_s.axi_awaddr) >= unsigned(SLAVE2_BASE_ADDR_a) and
           unsigned(m_axi_intf_s.axi_awaddr) <= unsigned(SLAVE2_HIGH_ADDR_a)) or
          (unsigned(m_axi_intf_s.axi_araddr) >= unsigned(SLAVE2_BASE_ADDR_a) and
           unsigned(m_axi_intf_s.axi_araddr) <= unsigned(SLAVE2_HIGH_ADDR_a)) then
      slave_sel <= 2;
    else
      slave_sel <= 0; -- No slave selected
    end if;
  end process;

  -- Multiplexing logic for write address channel
  s1_axi_intf_s.axi_awaddr  <= m_axi_intf_s.axi_awaddr when slave_sel = 1 else (others => '0');
  s1_axi_intf_s.axi_awvalid <= m_axi_intf_s.axi_awvalid when slave_sel = 1 else '0';
  s2_axi_intf_s.axi_awaddr  <= m_axi_intf_s.axi_awaddr when slave_sel = 2 else (others => '0');
  s2_axi_intf_s.axi_awvalid <= m_axi_intf_s.axi_awvalid when slave_sel = 2 else '0';

  -- Multiplexing logic for write data channel
  s1_axi_intf_s.axi_wdata   <= m_axi_intf_s.axi_wdata when slave_sel = 1 else (others => '0');
  s1_axi_intf_s.axi_wvalid  <= m_axi_intf_s.axi_wvalid when slave_sel = 1 else '0';
  s2_axi_intf_s.axi_wdata   <= m_axi_intf_s.axi_wdata when slave_sel = 2 else (others => '0');
  s2_axi_intf_s.axi_wvalid  <= m_axi_intf_s.axi_wvalid when slave_sel = 2 else '0';

  -- Multiplexing logic for read address channel
  s1_axi_intf_s.axi_araddr  <= m_axi_intf_s.axi_araddr when slave_sel = 1 else (others => '0');
  s1_axi_intf_s.axi_arvalid <= m_axi_intf_s.axi_arvalid when slave_sel = 1 else '0';
  s2_axi_intf_s.axi_araddr  <= m_axi_intf_s.axi_araddr when slave_sel = 2 else (others => '0');
  s2_axi_intf_s.axi_arvalid <= m_axi_intf_s.axi_arvalid when slave_sel = 2 else '0';

  -- Multiplexing logic for response channels
  m_axi_intf_s.axi_awready <= s1_axi_intf_s.axi_awready when slave_sel = 1 else
                   s2_axi_intf_s.axi_awready when slave_sel = 2 else
                   '0';
  m_axi_intf_s.axi_wready  <= s1_axi_intf_s.axi_wready when slave_sel = 1 else
                   s2_axi_intf_s.axi_wready when slave_sel = 2 else
                   '0';
  m_axi_intf_s.axi_bresp   <= s1_axi_intf_s.axi_bresp when slave_sel = 1 else
                   s2_axi_intf_s.axi_bresp when slave_sel = 2 else
                   "00";
  m_axi_intf_s.axi_bvalid  <= s1_axi_intf_s.axi_bvalid when slave_sel = 1 else
                   s2_axi_intf_s.axi_bvalid when slave_sel = 2 else
                   '0';
  m_axi_intf_s.axi_arready <= s1_axi_intf_s.axi_arready when slave_sel = 1 else
                   s2_axi_intf_s.axi_arready when slave_sel = 2 else
                   '0';
  m_axi_intf_s.axi_rdata   <= s1_axi_intf_s.axi_rdata when slave_sel = 1 else
                   s2_axi_intf_s.axi_rdata when slave_sel = 2 else
                   (others => '0');
  m_axi_intf_s.axi_rresp   <= s1_axi_intf_s.axi_rresp when slave_sel = 1 else
                   s2_axi_intf_s.axi_rresp when slave_sel = 2 else
                   "00";
  m_axi_intf_s.axi_rvalid  <= s1_axi_intf_s.axi_rvalid when slave_sel = 1 else
                   s2_axi_intf_s.axi_rvalid when slave_sel = 2 else
                   '0';

  -- Connect BREADY and RREADY signals
  s1_axi_intf_s.axi_bready <= m_axi_intf_s.axi_bready;
  s2_axi_intf_s.axi_bready <= m_axi_intf_s.axi_bready;
  s1_axi_intf_s.axi_rready <= m_axi_intf_s.axi_rready;
  s2_axi_intf_s.axi_rready <= m_axi_intf_s.axi_rready;