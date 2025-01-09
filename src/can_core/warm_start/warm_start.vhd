library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity warm_start is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        rxd_sync_i          : in    std_logic;
        sample_i            : in    std_logic;

        rxd_sync_o          : out   std_logic
    );
end entity;

architecture rtl of warm_start is

    signal cnt_s            : unsigned(3 downto 0);

begin

    rxd_sync_o  <= '1' when cnt_s > 0  else rxd_sync_i;

    warm_start_p : process(clk)
    begin 
        if rising_edge(clk) then
            cnt_s                   <= cnt_s;

            if cnt_s > 0 then
                if rxd_sync_i = '1' and sample_i = '1' then
                    cnt_s           <= cnt_s - 1;
                end if;

                if rxd_sync_i = '0' and sample_i = '1' then
                    cnt_s           <= to_unsigned(7, cnt_s'length);
                end if;
            end if;

            if rst_n = '0' then
                cnt_s           <= to_unsigned(7, cnt_s'length);
            end if;
        end if;
    end process warm_start_p;

end rtl;