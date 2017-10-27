{
    TFile f("/Users/baiy/WorkArea/CEPC/templatefit/20161128/templates/eeh/eeh_template_20by20.root","read");
    TH2D * h_bb = (TH2D*)f.Get("temsigb");
    TH2D * h_cc = (TH2D*)f.Get("temsigc");
    TH2D * h_gg = (TH2D*)f.Get("temsigg");
    TH2D * h_bkg = (TH2D*)f.Get("bkg");
    TH2D * h_hbkg =(TH2D*)f.Get("temsighbkg");
    TH2D * h_data = (TH2D*)f.Get("data");
    

    TCanvas *c1 = new TCanvas("c1","c1",800,600);
    c1->cd();

    TLatex * CEPC = new TLatex(0.46,0.73, "CEPC");
    CEPC->SetNDC();
    CEPC->SetTextFont(22);
    CEPC->SetTextSize(0.075);
    CEPC->SetTextAlign(33);

    TLatex * prelim = new TLatex(0.46,0.65, "Preliminary");
    prelim->SetNDC();
    prelim->SetTextFont(22);
    prelim->SetTextSize(0.05);
    prelim->SetTextAlign(33);

    h_bb->SetStats(kFALSE);
    h_cc->SetStats(kFALSE);
    h_gg->SetStats(kFALSE);
    h_data->SetStats(kFALSE);
    h_bkg->SetStats(kFALSE);
    h_hbkg->SetStats(kFALSE);

    h_bb->GetXaxis()->SetTitle("BLikeness");
    h_bb->GetYaxis()->SetTitle("CLikeness");
    h_cc->GetXaxis()->SetTitle("BLikeness");
    h_cc->GetYaxis()->SetTitle("CLikeness");
    h_gg->GetXaxis()->SetTitle("BLikeness");
    h_gg->GetYaxis()->SetTitle("CLikeness");
    h_bkg->GetXaxis()->SetTitle("BLikeness");
    h_bkg->GetYaxis()->SetTitle("CLikeness");
    h_hbkg->GetXaxis()->SetTitle("BLikeness");
    h_hbkg->GetYaxis()->SetTitle("CLikeness");
    h_data->GetXaxis()->SetTitle("BLikeness");
    h_data->GetYaxis()->SetTitle("CLikeness");

    h_bb->SetTitleOffset(2,"X");
    h_bb->SetTitleOffset(2,"Y");
    h_cc->SetTitleOffset(2,"X");
    h_cc->SetTitleOffset(2,"Y");
    h_gg->SetTitleOffset(2,"X");
    h_gg->SetTitleOffset(2,"Y");
    h_bkg->SetTitleOffset(2,"X");
    h_bkg->SetTitleOffset(2,"Y");
    h_hbkg->SetTitleOffset(2,"X");
    h_hbkg->SetTitleOffset(2,"Y");
    h_data->SetTitleOffset(2,"X");
    h_data->SetTitleOffset(2,"Y");

    TH1D * h_bkg_2 = h_bkg.Clone();
    h_bkg_2->Add(h_hbkg);


    h_data->Draw("Lego2");
    CEPC->Draw("same");
    prelim->Draw("same");
    c1->Print("eeh_data.pdf");
      
}
