<!-- GUI extras =========================================================-->
<table width=600><tr><td>
<b>FFTGEN NOTES:</b><br>
<i><small>
To use the FFT generator choose a value for </i>n_fft_points<i>
and </i>units_per_cycle<i>, then click the <br><b>"Submit changes"</b> button.
For a simple example, choose 8 </i>n_fft_points<i> and 2
</i>units_per_cycle<i>.  This builds an FFT that uses two butterfly
units and eight banks of SRAM.

<p>After clicking "Submit changes," the generator builds the desired FFT.
<s>
Then if you like, you can click <br><b>"Amazing FFT test5"</b> below to use the
FFT to calculate the transform of an input square wave.
</s>
And/or click
"download current design" to get source files for the FFT that you
generated.

<p><b>[SORRY!  For security reasons the amazing FFT5 test has been disabled.]</b>

<p>For now, the only </i>op_width<i> that works is "64".  The
generator will (silently) override any other op_width you try to
choose.  Also, for now, only "TEST5" </i>test_mode<i> is supported,
it will probably break if you try anything else.  Also note that
"TEST5" overrides op_width.

<!-- OOPS NO WAY TO GET THESE DOCS INTO THE GUI?
<p>A block diagram of the FFT can be found here:
<a href=/doc/BlockDiagrams_v2.pdf>doc/BlockDiagrams_v2.pdf</a>
and a sample waveform is here:
<a href=/doc/doc/dve_8_2_2port.pdf>doc/dve_8_2_2port.pdf</a>
-->

</small></i>
</td></tr></table>
<p>
<table class=top_stack_button><tr><td>
  <input
        type="button" id="downloadbutton"
    onclick="window.location=CGI_URL+'/do_anything.pl?../designs/FFTGenerator/&/home/steveri/fft/fftgen&bin/sorry.csh'"
    value="Amazing FFT test5."
  >
</td></tr></table>

<br>
