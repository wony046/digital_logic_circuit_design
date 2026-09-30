--------------------------------------------------------------------------------
-- Project : NOT Gate (VHDL workflow practice)
-- File    : not_gate.vhd
-- Author  : Unkyoung Won / 2023010519
-- Date    : 2026-09-30
--
--------------------------------------------------------------------------------
-- Description :
--   입력 a를 반전하여 출력 y로 내보내는 1비트 NOT 게이트.
--   a = '0' 이면 y = '1', a = '1' 이면 y = '0'.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- 외형 정의: 입력 핀 a, 출력 핀 y
entity not_gate is
  port (
    a : in  std_logic;   -- 입력
    y : out std_logic    -- 출력
  );
end entity not_gate;

-- 내부 동작 정의: y는 항상 a의 반전 값
architecture behavioral of not_gate is
begin
  y <= not a;
end architecture behavioral;
