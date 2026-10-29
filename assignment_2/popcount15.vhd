library ieee;
use ieee.std_logic_1164.all;

entity popcount15 is
    port (
        vt                  : in  std_logic_vector(14 downto 0);
        en                  : in  std_logic;
        a, b, c, d, e, f, g : out std_logic;
        dp                  : out std_logic
    );
end entity popcount15;

architecture behavioral of popcount15 is
    signal segments : std_logic_vector(6 downto 0);
begin
    process(vt, en)
        variable count : integer range 0 to 15;
    begin
        count := 0;
        for i in vt'range loop
            if vt(i) = '1' then
                count := count + 1;
            end if;
        end loop;

        if en = '1' then
            case count is
                when 0      => segments <= "1111110";
                when 1      => segments <= "0110000";
                when 2      => segments <= "1101101";
                when 3      => segments <= "1111001";
                when 4      => segments <= "0110011";
                when 5      => segments <= "1011011";
                when 6      => segments <= "1011111";
                when 7      => segments <= "1110000";
                when 8      => segments <= "1111111";
                when 9      => segments <= "1111011";
                when 10     => segments <= "1110111";
                when 11     => segments <= "0011111";
                when 12     => segments <= "1001110";
                when 13     => segments <= "0111101";
                when 14     => segments <= "1001111";
                when 15     => segments <= "1000111";
                when others => segments <= "0000000";
            end case;
        else
            segments <= "0000000";
        end if;
    end process;

    a <= segments(6);
    b <= segments(5);
    c <= segments(4);
    d <= segments(3);
    e <= segments(2);
    f <= segments(1);
    g <= segments(0);
    dp <= '0';
end architecture behavioral;
