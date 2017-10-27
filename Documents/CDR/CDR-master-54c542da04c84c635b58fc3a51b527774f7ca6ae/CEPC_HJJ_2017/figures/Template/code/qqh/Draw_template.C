{
    TFile f("/Users/baiy/WorkArea/CEPC/templatefit/20161128/templates/qqh/qqh_template_20by20.root","read");
    TH2D * h_bb = (TH2D*)f.Get("qqh_bb");
    TH2D * h_cc = (TH2D*)f.Get("qqh_cc");
    TH2D * h_gg = (TH2D*)f.Get("qqh_gg");
    TH2D * h_data = (TH2D*)f.Get("data");
    TH2D * h_hbkg = (TH2D*)f.Get("qqh_bkg");
    TH2D * h_bkg = (TH2D*)f.Get("bkg");

    TH2D *eeh_bb = (TH2D*)f.Get("eeh_bb");
    TH2D *eeh_cc = (TH2D*)f.Get("eeh_cc");
    TH2D *eeh_gg = (TH2D*)f.Get("eeh_gg");
    TH2D *eeh_bkg = (TH2D*)f.Get("eeh_bkg");
    TH2D *mumuh_bb = (TH2D*)f.Get("mumuh_bb");
    TH2D *mumuh_cc = (TH2D*)f.Get("mumuh_cc");
    TH2D *mumuh_gg = (TH2D*)f.Get("mumuh_gg");
    TH2D *mumuh_bkg = (TH2D*)f.Get("mumuh_bkg");
    TH2D *nnh_bb = (TH2D*)f.Get("nnh_bb");
    TH2D *nnh_cc = (TH2D*)f.Get("nnh_cc");
    TH2D *nnh_gg = (TH2D*)f.Get("nnh_gg");
    TH2D *nnh_bkg = (TH2D*)f.Get("nnh_bkg");

    h_bkg->Add(eeh_bb);h_bkg->Add(eeh_cc); h_bkg->Add(eeh_gg);h_bkg->Add(eeh_bkg);
    h_bkg->Add(mumuh_bb);h_bkg->Add(mumuh_cc); h_bkg->Add(mumuh_gg);h_bkg->Add(mumuh_bkg);
    h_bkg->Add(nnh_bb);h_bkg->Add(nnh_cc); h_bkg->Add(nnh_gg);h_bkg->Add(nnh_bkg);

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
    h_bkg->SetStats(kFALSE);
    h_data->SetStats(kFALSE);

    h_bb->GetXaxis()->SetTitle("BLikeness");
    h_bb->GetYaxis()->SetTitle("CLikeness");
    h_cc->GetXaxis()->SetTitle("BLikeness");
    h_cc->GetYaxis()->SetTitle("CLikeness");
    h_gg->GetXaxis()->SetTitle("BLikeness");
    h_gg->GetYaxis()->SetTitle("CLikeness");
    h_bkg->GetXaxis()->SetTitle("BLikeness");
    h_bkg->GetYaxis()->SetTitle("CLikeness");
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
    h_data->SetTitleOffset(2,"X");
    h_data->SetTitleOffset(2,"Y");


    TH1D * h_bkg_2 = h_bkg.Clone();
    h_bkg_2.Add(h_hbkg);

    h_bkg_2->Draw("Lego2");
    CEPC->Draw("same");
    prelim->Draw("same");
    c1->Print("qqh_bkg.pdf");
      
}
