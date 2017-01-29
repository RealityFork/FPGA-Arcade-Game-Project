LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vga IS
	GENERIC(
		h_pixels	:	INTEGER := 800;		-- Number of pixels along X
		v_pixels	:	INTEGER := 600;		-- Number of pixels along Y
		
		h_pulse 	:	INTEGER := 128;    	-- Sync pulse width in pixels
		v_pulse 	:	INTEGER := 4;		-- Sync pulse height in pixels
		
		h_bp	 	:	INTEGER := 88;	   	-- Porch widths in pixels
		h_fp	 	:	INTEGER := 40;
		v_bp	 	:	INTEGER := 23;
		v_fp	 	:	INTEGER := 1;
		
		h_pol		:	STD_LOGIC := '1';	-- Sync pulse polarity (1 = positive, 0 = negative)
		v_pol		:	STD_LOGIC := '1');
		
		
	PORT(
		pixel_clk	:	IN	STD_LOGIC;	-- 40Mhz
		h_sync		:	OUT	STD_LOGIC;	-- Sync output
		v_sync		:	OUT	STD_LOGIC;
		column		:	OUT	INTEGER;	-- X coordinate
		row			:	OUT	INTEGER;	-- Y coordinate
		n_blank		:	OUT	STD_LOGIC;	-- Direct blacking output to DAC
		h_blank     :  	OUT  STD_LOGIC; -- h and v blanking 
		v_blank     :  	OUT  STD_LOGIC);
END vga;

ARCHITECTURE behaviour OF vga IS
	CONSTANT	h_period	:	INTEGER := h_pulse + h_bp + h_pixels + h_fp;  -- Total row length
	CONSTANT	v_period	:	INTEGER := v_pulse + v_bp + v_pixels + v_fp;  -- Total column length
BEGIN
	
	PROCESS(pixel_clk)
		VARIABLE h_count	:	INTEGER RANGE 0 TO h_period - 1 := 0;  -- Horizontal counter (counts the columns)
		VARIABLE v_count	:	INTEGER RANGE 0 TO v_period - 1 := 0;  -- Vertical counter (counts the rows)
	BEGIN
		
		-- RISING EDGE --
		IF(pixel_clk'EVENT AND pixel_clk = '1') THEN

		
			--Increment counters
			IF(h_count < h_period - 1) THEN
				h_count := h_count + 1;
			ELSE
				h_count := 0;
				IF(v_count < v_period - 1) THEN
					v_count := v_count + 1;
				ELSE
					v_count := 0;
				END IF;
			END IF;
			-------------------

			-- Set sync between FP and BP
			IF(h_count < h_pixels + h_fp OR h_count > h_pixels + h_fp + h_pulse) THEN
				h_sync <= NOT h_pol;
			ELSE
				h_sync <= h_pol;
			END IF;
			------------------------
			
			-- Set sync between FP and BP
			IF(v_count < v_pixels + v_fp OR v_count > v_pixels + v_fp + v_pulse) THEN
				v_sync <= NOT v_pol;
			ELSE
				v_sync <= v_pol;
			END IF;
			----------------------
			
			-- Set x and y co-ords
			IF(h_count < h_pixels) THEN
				column <= h_count;
			END IF;
			IF(v_count < v_pixels) THEN
				row <= v_count;
			END IF;
			------------------------

			-- Set display enable output
			IF(h_count < h_pixels AND v_count < v_pixels) THEN  	--display time
				n_blank <= '1';
			ELSE
				n_blank <= '0';
			END IF;
			-------------------------
			
			-- Separate h and v blanking signals
			IF (h_count >= h_pixels) THEN
				h_blank <= '1';
			ELSE
				h_blank <= '0';
			END IF;
			IF (v_count >= v_pixels) THEN
				v_blank <= '1';
			ELSE
				v_blank <= '0';
			END IF;
			-------------------------

		END IF;
	END PROCESS;

END behaviour;