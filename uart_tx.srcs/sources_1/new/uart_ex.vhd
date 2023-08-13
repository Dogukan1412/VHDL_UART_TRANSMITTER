library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_ex is
  Generic(
	clk_freq 				: integer 		:= 100_000_000;
	baud_rate				: integer 		:= 115_200;
	stop_bit				: integer		:= 2
  );		
  Port (		
	start_bit 				: in std_logic;
	clk 					: in std_logic;
	data_i					: in std_logic_vector(7 downto 0);
	transmitter_o			: out std_logic;
	transmitter_done		: out std_logic
  );
end uart_ex;

architecture Behavioral of uart_ex is

type state is (IDLE, START, DATA, STOP);
signal s_state 				: state := IDLE;
	
signal shft_reg 			: std_logic_vector(7 downto 0) := "00000000";
signal bit_counter			: integer range 0 to 7 := '0';
signal bit_timer			: integer range  0 to stop_bit_lim := '0';

constant bit_timer_lim 		: integer range 0 to clk_freq/baud_rate;
constant stop_bit_lim		: integer range 0 to bit_timer_lim*stop_bit;

begin
	
	process(clk) begin
		if(rising_edge(clk)) then
			case state is
				when IDLE 	=>
				
					transmitter_o 				<= '1';
					transmitter_done 			<= '0';
					bit_counter 				<= '0';
					
					if(start_bit = '1') then
						state 					<= START;
						shft_reg 				<= data_i;
						transmitter_o 			<= '0';
					end if;
					
					
				when START	=>
				
					if(bit_timer = bit_timer_lim - 1) then
						state 					<= DATA;
						transmitter_o 			<= shft_reg(0);
						shft_reg(7) 			<= shft_reg(0);
						shft_reg(6 downto 0)  	<= shft_reg(7 downto 1);
						bit_timer 				<= 0;
					else
						bit_timer 				<= bit_timer + 1;
					end if;
				
				
				when DATA 	=>
					
					if(bit_counter = '7') then 
						if(bit_timer = bit_timer_lim - 1) then
							bit_counter 		<= 0;
							bit_timer 			<= 0;
							state 				<= STOP;
							transmitter_o 				<= '1';
							
						else
							bit_timer 			<= bit_timer + 1;
						end if;					
						
					else
						if(bit_timer = bit_timer_lim - 1) then
							bit_counter <= bit_counter + 1;
							shft_reg(7) 		<= shft_reg(0);
							shft_reg(6 downto 0)<= shft_reg(7 downto 1);
							transmitter_o 		<= shft_reg(0);
							bit_timer 			<= 0;
						else
							bit_timer 			<= bit_timer + 1;
						end if;
					end if;
				
				
				when STOP 	=>
					if(bit_timer = bit_timer_lim - 1) then
						state 					<= IDLE;
						transmitter_done 		<= '1';
						bit_timer				<= 0;
					else
						bit_timer 				<= bit_timer + 1;
					end if;
				
			end case;
		end if;
	end process;

end Behavioral;
