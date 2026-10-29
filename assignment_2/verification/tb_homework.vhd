library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_homework is
end entity tb_homework;

architecture test of tb_homework is
    type segment_table is array (natural range <>) of std_logic_vector(6 downto 0);
    constant digit_segments : segment_table(0 to 15) := (
        "1111110", "0110000", "1101101", "1111001",
        "0110011", "1011011", "1011111", "1110000",
        "1111111", "1111011", "1110111", "0011111",
        "1001110", "0111101", "1001111", "1000111"
    );
    constant letter_segments : segment_table(0 to 7) := (
        "1111101", "0011111", "0001101", "0111101",
        "1000111", "1111011", "0000000", "0000000"
    );
    signal logic_inputs : std_logic_vector(3 downto 0) := (others => '0');
    signal logic_and, logic_or : std_logic;
    signal mux_inputs : std_logic_vector(7 downto 0) := (others => '0');
    signal mux_sel : std_logic_vector(2 downto 0) := (others => '0');
    signal mux_y : std_logic;
    signal letter_sel : std_logic_vector(2 downto 0) := (others => '0');
    signal letter_output : std_logic_vector(7 downto 0);
    signal vote_input : std_logic_vector(24 downto 0) := (others => '0');
    signal vote_result : std_logic;
    signal count_input : std_logic_vector(14 downto 0) := (others => '0');
    signal count_enable : std_logic := '0';
    signal count_output : std_logic_vector(7 downto 0);
begin
    dut_logic : entity work.logic4
        port map (
            a => logic_inputs(3), b => logic_inputs(2),
            c => logic_inputs(1), d => logic_inputs(0),
            out1 => logic_and, out2 => logic_or
        );

    dut_mux : entity work.mux8
        port map (
            a => mux_inputs(0), b => mux_inputs(1),
            c => mux_inputs(2), d => mux_inputs(3),
            e => mux_inputs(4), f => mux_inputs(5),
            g => mux_inputs(6), h => mux_inputs(7),
            sel => mux_sel, y => mux_y
        );

    dut_letters : entity work.letters7seg
        port map (
            sel => letter_sel,
            a => letter_output(7), b => letter_output(6),
            c => letter_output(5), d => letter_output(4),
            e => letter_output(3), f => letter_output(2),
            g => letter_output(1), dp => letter_output(0)
        );

    dut_vote : entity work.vote25
        port map (vt => vote_input, result => vote_result);

    dut_count : entity work.popcount15
        port map (
            vt => count_input, en => count_enable,
            a => count_output(7), b => count_output(6),
            c => count_output(5), d => count_output(4),
            e => count_output(3), f => count_output(2),
            g => count_output(1), dp => count_output(0)
        );

    stimulus : process
        variable data8 : std_logic_vector(7 downto 0);
        variable data15 : std_logic_vector(14 downto 0);
        variable votes : std_logic_vector(24 downto 0);
        variable ones : integer;
        variable vote_tests : integer := 0;
    begin
        for input_i in 0 to 15 loop
            logic_inputs <= std_logic_vector(to_unsigned(input_i, 4));
            wait for 1 ns;
            if input_i = 15 then
                assert logic_and = '1' report "logic4 AND failed" severity failure;
            else
                assert logic_and = '0' report "logic4 AND failed" severity failure;
            end if;
            if input_i = 0 then
                assert logic_or = '0' report "logic4 OR failed" severity failure;
            else
                assert logic_or = '1' report "logic4 OR failed" severity failure;
            end if;
        end loop;
        report "PASS logic4 cases=16" severity note;

        for data_i in 0 to 255 loop
            data8 := std_logic_vector(to_unsigned(data_i, 8));
            mux_inputs <= data8;
            for select_i in 0 to 7 loop
                mux_sel <= std_logic_vector(to_unsigned(select_i, 3));
                wait for 1 ns;
                assert mux_y = data8(select_i)
                    report "mux8 failed data=" & integer'image(data_i) &
                        " select=" & integer'image(select_i)
                    severity failure;
            end loop;
        end loop;
        report "PASS mux8 cases=2048" severity note;

        for select_i in 0 to 7 loop
            letter_sel <= std_logic_vector(to_unsigned(select_i, 3));
            wait for 1 ns;
            assert letter_output = letter_segments(select_i) & '0'
                report "letters7seg failed select=" & integer'image(select_i)
                severity failure;
        end loop;
        report "PASS letters7seg cases=8" severity note;

        for count_i in 0 to 25 loop
            votes := (others => '0');
            for bit_i in 0 to 24 loop
                if bit_i < count_i then
                    votes(bit_i) := '1';
                end if;
            end loop;
            vote_input <= votes;
            wait for 1 ns;
            if count_i >= 13 then
                assert vote_result = '1' report "vote25 count failed" severity failure;
            else
                assert vote_result = '0' report "vote25 count failed" severity failure;
            end if;
            vote_tests := vote_tests + 1;
        end loop;

        for count_i in 12 to 13 loop
            for shift_i in 0 to 24 loop
                votes := (others => '0');
                for bit_i in 0 to count_i - 1 loop
                    votes((bit_i + shift_i) mod 25) := '1';
                end loop;
                vote_input <= votes;
                wait for 1 ns;
                if count_i = 13 then
                    assert vote_result = '1' report "vote25 boundary failed" severity failure;
                else
                    assert vote_result = '0' report "vote25 boundary failed" severity failure;
                end if;
                vote_tests := vote_tests + 1;
            end loop;
        end loop;
        report "PASS vote25 cases=" & integer'image(vote_tests) severity note;

        for input_i in 0 to 32767 loop
            data15 := std_logic_vector(to_unsigned(input_i, 15));
            ones := 0;
            for bit_i in data15'range loop
                if data15(bit_i) = '1' then
                    ones := ones + 1;
                end if;
            end loop;
            count_input <= data15;
            count_enable <= '0';
            wait for 1 ns;
            assert count_output = "00000000"
                report "popcount15 disabled failed input=" & integer'image(input_i)
                severity failure;
            count_enable <= '1';
            wait for 1 ns;
            assert count_output = digit_segments(ones) & '0'
                report "popcount15 enabled failed input=" & integer'image(input_i)
                severity failure;
        end loop;
        report "PASS popcount15 cases=65536" severity note;
        report "ALL_TESTS_PASSED total_cases=67684" severity note;
        wait;
    end process;
end architecture test;
