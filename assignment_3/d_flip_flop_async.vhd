library ieee;
use ieee.std_logic_1164.all;

entity d_flip_flop_async is
    port (d, clk, set, clr : in std_logic;
          q : out std_logic);
end entity d_flip_flop_async;

architecture rtl of d_flip_flop_async is
begin
    process(clk, set, clr)
    begin
        if clr = '1' then
            q <= '0';
        elsif set = '1' then
            q <= '1';
        elsif rising_edge(clk) then
            q <= d;
        end if;
    end process;
end architecture rtl;
