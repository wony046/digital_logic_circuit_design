library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;

entity tb_sequential is
end entity;

architecture test of tb_sequential is
    signal rs_s, rs_r : std_logic := '0';
    signal rs_q, rs_qbar : std_logic;
    signal dl_d, dl_en : std_logic := '0';
    signal dl_q : std_logic;
    signal df_d, df_clk : std_logic := '0';
    signal df_q : std_logic;
    signal jk_j, jk_k, jk_clk : std_logic := '0';
    signal jk_q : std_logic;
    signal af_d, af_clk, af_set, af_clr : std_logic := '0';
    signal af_q : std_logic;
begin
    dut_rs : entity work.rs_latch port map(rs_s, rs_r, rs_q, rs_qbar);
    dut_dl : entity work.d_latch port map(dl_d, dl_en, dl_q);
    dut_df : entity work.d_flip_flop port map(df_d, df_clk, df_q);
    dut_jk : entity work.jk_flip_flop port map(jk_j, jk_k, jk_clk, jk_q);
    dut_af : entity work.d_flip_flop_async port map(af_d, af_clk, af_set, af_clr, af_q);

    stimulus : process
        file trace : text open write_mode is "vhdl_samples.csv";
        variable row : line;
        variable total, section_start : natural := 0;
        variable expected, d_bit, set_bit, clr_bit : std_logic;
        function bit_value(value : natural) return std_logic is
        begin
            if value = 0 then return '0'; else return '1'; end if;
        end function;
        procedure field(value : std_logic) is
            variable text_value : string(1 to 3);
        begin
            text_value := std_logic'image(value);
            write(row, string'(","));
            write(row, text_value(2));
        end procedure;
        procedure check(signal actual : in std_logic;
                        target : std_logic; label_text : string) is
        begin
            total := total + 1;
            assert actual = target
                report "FAIL " & label_text & " expected=" & std_logic'image(target) &
                       " actual=" & std_logic'image(actual)
                severity failure;
            write(row, integer'image(integer(now / 1 ns)));
            write(row, string'(",")); write(row, label_text);
            field(rs_s); field(rs_r); field(rs_q); field(rs_qbar);
            field(dl_d); field(dl_en); field(dl_q);
            field(df_d); field(df_clk); field(df_q);
            field(jk_j); field(jk_k); field(jk_clk); field(jk_q);
            field(af_d); field(af_clk); field(af_set); field(af_clr); field(af_q);
            writeline(trace, row);
        end procedure;
        procedure pass(name : string) is
        begin
            report "PASS " & name & " cases=" & integer'image(total - section_start);
            section_start := total;
        end procedure;
    begin
        write(row, string'("time_ns,case,rs_s,rs_r,rs_q,rs_qbar,dl_d,dl_en,dl_q,df_d,df_clk,df_q,jk_j,jk_k,jk_clk,jk_q,af_d,af_clk,af_set,af_clr,af_q"));
        writeline(trace, row);
        rs_r <= '1'; wait for 10 ns;
        check(rs_q, '0', "rs_reset_q"); check(rs_qbar, '1', "rs_reset_qbar");
        rs_r <= '0'; wait for 10 ns;
        check(rs_q, '0', "rs_hold_zero");
        rs_s <= '1'; wait for 10 ns;
        check(rs_q, '1', "rs_set_q"); check(rs_qbar, '0', "rs_set_qbar");
        rs_s <= '0'; wait for 10 ns;
        check(rs_q, '1', "rs_hold_one");
        rs_s <= '1'; rs_r <= '1'; wait for 10 ns;
        check(rs_q, '0', "rs_forbidden_q"); check(rs_qbar, '0', "rs_forbidden_qbar");
        rs_s <= '0'; wait for 10 ns;
        check(rs_q, '0', "rs_recover_reset_q"); check(rs_qbar, '1', "rs_recover_reset_qbar");
        rs_r <= '0'; wait for 10 ns;
        check(rs_q, '0', "rs_recover_hold");
        pass("rs_latch");

        dl_en <= '1'; dl_d <= '0'; wait for 10 ns; check(dl_q, '0', "dl_load_zero");
        for repeat_index in 0 to 2 loop
            dl_d <= '1'; wait for 10 ns; check(dl_q, '1', "dl_transparent_one");
            dl_d <= '0'; wait for 10 ns; check(dl_q, '0', "dl_transparent_zero");
        end loop;
        for stored in 0 to 1 loop
            dl_en <= '1'; dl_d <= bit_value(stored); wait for 10 ns;
            dl_en <= '0'; wait for 10 ns; check(dl_q, bit_value(stored), "dl_disable");
            dl_d <= not bit_value(stored); wait for 10 ns;
            check(dl_q, bit_value(stored), "dl_hold_changed_d");
            dl_d <= bit_value(stored); wait for 10 ns;
            check(dl_q, bit_value(stored), "dl_hold_restored_d");
        end loop;
        dl_en <= '1'; dl_d <= '1'; wait for 10 ns; check(dl_q, '1', "dl_reenable");
        pass("d_latch");

        df_clk <= '0'; df_d <= '0'; wait for 10 ns;
        df_clk <= '1'; wait for 10 ns; check(df_q, '0', "df_initialize_rising");
        expected := '0';
        for value in 0 to 3 loop
            d_bit := bit_value((value + 1) mod 2);
            df_d <= d_bit; wait for 10 ns;
            check(df_q, expected, "df_hold_high");
            df_clk <= '0'; wait for 10 ns;
            check(df_q, expected, "df_hold_falling");
            df_d <= not d_bit; wait for 10 ns;
            check(df_q, expected, "df_hold_low");
            df_d <= d_bit; wait for 10 ns;
            df_clk <= '1'; expected := d_bit; wait for 10 ns;
            check(df_q, expected, "df_capture_rising");
        end loop;
        pass("d_flip_flop");

        for initial in 0 to 1 loop
            for mode in 0 to 3 loop
                jk_clk <= '0'; jk_j <= bit_value(initial); jk_k <= not bit_value(initial);
                wait for 10 ns; jk_clk <= '1'; wait for 10 ns;
                expected := bit_value(initial);
                check(jk_q, expected, "jk_initialize");
                jk_j <= bit_value(mode / 2); jk_k <= bit_value(mode mod 2);
                wait for 10 ns; check(jk_q, expected, "jk_hold_high");
                jk_clk <= '0'; wait for 10 ns;
                check(jk_q, expected, "jk_hold_falling");
                jk_clk <= '1';
                case mode is
                    when 0 => null;
                    when 1 => expected := '0';
                    when 2 => expected := '1';
                    when others => expected := not expected;
                end case;
                wait for 10 ns; check(jk_q, expected, "jk_mode_" & integer'image(mode));
            end loop;
        end loop;
        jk_j <= '1'; jk_k <= '1';
        for value in 0 to 3 loop
            jk_clk <= '0'; wait for 10 ns;
            check(jk_q, expected, "jk_toggle_falling_hold");
            jk_clk <= '1'; expected := not expected; wait for 10 ns;
            check(jk_q, expected, "jk_repeat_toggle");
        end loop;
        pass("jk_flip_flop");

        af_clr <= '1'; wait for 10 ns; check(af_q, '0', "af_initialize_clear");
        for clock_level in 0 to 1 loop
            af_clk <= bit_value(clock_level); wait for 10 ns;
            for data_value in 0 to 1 loop
                for controls in 1 to 3 loop
                    af_set <= '0'; af_clr <= '1'; wait for 10 ns;
                    af_d <= bit_value(data_value);
                    set_bit := bit_value(controls mod 2);
                    clr_bit := bit_value(controls / 2);
                    af_set <= set_bit; af_clr <= clr_bit; wait for 10 ns;
                    if clr_bit = '1' then expected := '0'; else expected := '1'; end if;
                    check(af_q, expected, "af_async_controls_" & integer'image(controls));
                end loop;
            end loop;
        end loop;
        af_clk <= '0'; af_set <= '1'; af_clr <= '0'; wait for 10 ns;
        check(af_q, '1', "af_set_before_release");
        af_set <= '0'; af_d <= '0'; wait for 10 ns;
        check(af_q, '1', "af_release_holds_set");
        af_clk <= '1'; wait for 10 ns; check(af_q, '0', "af_normal_capture_zero");
        af_d <= '1'; wait for 10 ns; check(af_q, '0', "af_normal_hold_high");
        af_clk <= '0'; wait for 10 ns; check(af_q, '0', "af_normal_hold_falling");
        af_clk <= '1'; wait for 10 ns; check(af_q, '1', "af_normal_capture_one");
        af_clr <= '1'; af_set <= '1'; wait for 10 ns;
        check(af_q, '0', "af_clear_priority_high");
        af_clk <= '0'; wait for 10 ns; check(af_q, '0', "af_clear_priority_low");
        af_clr <= '0'; wait for 10 ns; check(af_q, '1', "af_clear_release_set_stays");
        af_set <= '0'; af_d <= '0'; wait for 10 ns;
        check(af_q, '1', "af_release_both_holds");
        af_clk <= '1'; wait for 10 ns; check(af_q, '0', "af_capture_after_release");
        af_clr <= '1'; wait for 10 ns; check(af_q, '0', "af_clear_without_clock");
        af_clr <= '0'; af_d <= '1'; wait for 10 ns;
        check(af_q, '0', "af_clear_release_holds");
        af_set <= '1'; wait for 10 ns;
        check(af_q, '1', "af_set_high_without_clock");
        af_set <= '0'; af_d <= '0'; wait for 10 ns;
        check(af_q, '1', "af_set_release_while_clock_high");
        af_set <= '1'; af_clr <= '1'; wait for 10 ns;
        check(af_q, '0', "af_both_active_while_clock_high");
        af_clr <= '0'; wait for 10 ns;
        check(af_q, '1', "af_clear_release_set_high_clock_high");
        af_set <= '0'; wait for 10 ns;
        check(af_q, '1', "af_controls_release_high_holds");
        af_clk <= '0'; wait for 10 ns;
        check(af_q, '1', "af_controls_release_falling_holds");
        af_clk <= '1'; wait for 10 ns;
        check(af_q, '0', "af_controls_release_next_rising");
        pass("d_flip_flop_async");
        report "ALL_TESTS_PASSED total_cases=" & integer'image(total);
        finish;
        wait;
    end process;
end architecture;
