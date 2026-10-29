library ieee;
use ieee.std_logic_1164.all;

entity mux8 is
    port (
        a, b, c, d, e, f, g, h : in  std_logic;
        sel                     : in  std_logic_vector(2 downto 0);
        y                       : out std_logic
    );
end entity mux8;

architecture behavioral of mux8 is
begin
    with sel select
        y <= a   when "000",
             b   when "001",
             c   when "010",
             d   when "011",
             e   when "100",
             f   when "101",
             g   when "110",
             h   when "111",
             '0' when others;
end architecture behavioral;
