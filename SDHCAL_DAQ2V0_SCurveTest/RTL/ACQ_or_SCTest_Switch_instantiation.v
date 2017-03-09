ACQ_or_SCTest_Switch uut (
  .ACQ_or_SCTest(),
  /*--- USB Data FIFO write ---*/
  .Microroc_usb_data_fifo_wr_din(),
  .Microroc_usb_data_fifo_wr_en(),
  .SCTest_usb_data_fifo_wr_din(),
  .SCTest_usb_data_fifo_wr_en(),
  .out_to_usb_data_fifo_wr_din(),
  .out_to_usb_data_fifo_wr_en(),
  /*--- SC param ---*/
  // CTest Channel select
  .USB_Microroc_CTest_Chn_Out(),
  .SCTest_Microroc_CTest_Chn_Out(),
  .out_to_Microroc_CTest_Chn_Out(),
  // 10bit DAC code out
  .USB_Microroc_10bit_DAC_Out(),
  .SCTest_Microroc_10bit_DAC_Out(),
  .out_to_Microroc_10bit_DAC_Out(),
  // SC param load
  .USB_SC_Param_Load(),
  .SCTest_SC_Param_Load(),
  .out_to_Microroc_SC_Param_Load(),
  /*--- 3 triggers ---*/
  .Pin_out_trigger0b(),
  .Pin_out_trigger1b(),
  .Pin_out_trigger2b(),
  .SCTest_out_trigger0b(),
  .SCTest_out_trigger1b(),
  .SCTest_out_trigger2b(),
  .HoldGen_out_trigger0b(),
  .HoldGen_out_trigger1b(),
  .HoldGen_out_trigger2b()
);
