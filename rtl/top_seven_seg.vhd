library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_seven_seg is
    Port (
        clk : in  STD_LOGIC;                    -- Onboard 100MHz clock (Pin V10)
        rst : in  STD_LOGIC;                    -- Reset button (Switch 0 Pin T10)
        an  : out STD_LOGIC_VECTOR (3 downto 0); -- 7-segment anodes (active low)
        seg : out STD_LOGIC_VECTOR (7 downto 0)  -- 7-segment cathodes (active low)
    );
end top_seven_seg;

architecture Behavioral of top_seven_seg is
    -- 1. Clock Dividers & Data Registers
    signal one_sec_counter : unsigned(26 downto 0) := (others => '0'); -- Up to 100,000,000
    signal refresh_counter : unsigned(16 downto 0) := (others => '0'); -- For display scanning
    signal time_data       : unsigned(15 downto 0) := (others => '0'); -- Four 4-bit hex values
    
    signal active_digit    : std_logic_vector(1 downto 0);
    signal hex_digit       : std_logic_vector(3 downto 0);
begin

    -- Increment time data every 1 second (100 million clock cycles)
    process(clk, rst)
    begin
        if rst = '1' then
            one_sec_counter <= (others => '0');
            time_data       <= (others => '0');
        elsif rising_edge(clk) then
            if one_sec_counter >= 100000000 - 1 then
                one_sec_counter <= (others => '0');
                time_data       <= time_data + 1; -- Increment display counter
            else
                one_sec_counter <= one_sec_counter + 1;
            end if; -- <--- Fixed: Added missing end if for the inner loop
        end if; -- <--- Fixed: Added missing end if for the clock loop
    end process;

    -- Increment refresh counter constantly to scan through digits
    process(clk, rst)
    begin
        if rst = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- 2. Multiplexer: Select which digit to show based on top 2 bits of refresh counter
    active_digit <= std_logic_vector(refresh_counter(16 downto 15));

    process(active_digit, time_data)
    begin
        case active_digit is
            when "00" =>
                an <= "1110"; -- Enable rightmost digit
                hex_digit <= std_logic_vector(time_data(3 downto 0));
            when "01" =>
                an <= "1101"; 
                hex_digit <= std_logic_vector(time_data(7 downto 4));
            when "10" =>
                an <= "1011"; 
                hex_digit <= std_logic_vector(time_data(11 downto 8));
            when "11" =>
                an <= "0111"; -- Enable leftmost digit
                hex_digit <= std_logic_vector(time_data(15 downto 12));
            when others =>
                an <= "1111";
                hex_digit <= "0000";
        end case;
    end process;

    -- 3. Hex-to-7-Segment Decoder (Active LOW segments: CA CB CC CD CE CF CG DP)
    process(hex_digit)
    begin
        case hex_digit is
            when x"0" => seg <= "00000011"; -- 0
            when x"1" => seg <= "10011111"; -- 1
            when x"2" => seg <= "00100101"; -- 2
            when x"3" => seg <= "00001101"; -- 3
            when x"4" => seg <= "10011001"; -- 4
            when x"5" => seg <= "01001001"; -- 5
            when x"6" => seg <= "01000001"; -- 6
            when x"7" => seg <= "00011111"; -- 7
            when x"8" => seg <= "00000001"; -- 8
            when x"9" => seg <= "00001101"; -- 9
            when x"A" => seg <= "00010001"; -- A
            when x"B" => seg <= "11000001"; -- b
            when x"C" => seg <= "01100011"; -- C
            when x"D" => seg <= "10000101"; -- d
            when x"E" => seg <= "01100001"; -- E
            when x"F" => seg <= "01110001"; -- F
            when others => seg <= "11111111";
        end case;
    end process;

end Behavioral;
