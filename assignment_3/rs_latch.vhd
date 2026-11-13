library ieee;
use ieee.std_logic_1164.all;

entity rs_latch is
    port (s, r : in std_logic;
          q, qbar : out std_logic);
end entity rs_latch;

architecture rtl of rs_latch is
    signal q_i, qbar_i : std_logic;
begin
    q_i <= not (r or qbar_i);
    qbar_i <= not (s or q_i);
    q <= q_i;
    qbar <= qbar_i;
end architecture rtl;
