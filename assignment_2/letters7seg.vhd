library ieee;
use ieee.std_logic_1164.all;

entity letters7seg is
    port (
        sel                 : in  std_logic_vector(2 downto 0);
        a, b, c, d, e, f, g : out std_logic;
        dp                  : out std_logic
    );
end entity letters7seg;

architecture behavioral of letters7seg is
    signal segments : std_logic_vector(6 downto 0);
begin
    with sel select
        segments <= "1111101" when "000",
                    "0011111" when "001",
                    "0001101" when "010",
                    "0111101" when "011",
                    "1000111" when "100",
                    "1111011" when "101",
                    "0000000" when others;

    a <= segments(6);
    b <= segments(5);
    c <= segments(4);
    d <= segments(3);
    e <= segments(2);
    f <= segments(1);
    g <= segments(0);
    dp <= '0';
end architecture behavioral;
