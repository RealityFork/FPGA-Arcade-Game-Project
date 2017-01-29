library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity KBdriver is
	port (
		data    : out std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
		evType  : out std_logic;
		ps2data : in  std_logic;
		ps2clk  : in std_logic
		);
end entity;

architecture behaviour of KBdriver is
begin
	process (ps2clk)
	
	variable keyBuffer : std_logic_vector(15 downto 0) := (OTHERS => '0');
	variable byteBuffer: std_logic_vector(7 downto 0) := (OTHERS => '0');
	variable evBuffer  : std_logic;
	variable status    : integer range 0 to 10 := 0;
	
	begin
	
		if (falling_edge(ps2clk)) Then
			if (status > 0 and status < 9) Then
				byteBuffer(status-1) := ps2data;	--Clock in byte data
			end if;

			
			if (status = 10) then
				status := 0;
				if (byteBuffer = X"E0") then 					--if the received byte if 'E0', store in the high byte of the output buffer.
					keyBuffer(15 downto 8) := byteBuffer;
				elsif (byteBuffer = X"F0") then 				--if the received byte if F0, keyUp.
					evBuffer := '0';	
				else 													--otherwise set the output port to the value stored in the keybuffer along with most recent byte.
					keyBuffer(7 downto 0) := byteBuffer;
					data <= keyBuffer(15 downto 8) & byteBuffer;	--set output port to key data received
					evType <= evBuffer;								--indicate the type of event on the output port
					keyBuffer := (OTHERS => '0');
					evBuffer := '1';
				end if;
			else
				status := status + 1;
			end if;
		end if;
	end process;
end behaviour;