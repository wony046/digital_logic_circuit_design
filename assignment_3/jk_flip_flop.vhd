library ieee;
use ieee.std_logic_1164.all;

entity jk_flip_flop is
    port (j, k, clk : in std_logic;
          q : out std_logic);
end entity jk_flip_flop;

architecture rtl of jk_flip_flop is
    signal q_i : std_logic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if j = '0' and k = '0' then
                null;
            elsif j = '0' and k = '1' then
                q_i <= '0';
            elsif j = '1' and k = '0' then
                q_i <= '1';
            elsif j = '1' and k = '1' then
                q_i <= not q_i;
            end if;
        end if;
    end process;
    q <= q_i;
end architecture rtl;
