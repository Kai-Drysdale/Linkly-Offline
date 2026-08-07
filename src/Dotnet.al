dotnet
{
    assembly("MCS.NAV.PcEftPos")
    {
        Culture = 'neutral';
        //PublicKeyToken = null;
        Version = '1.0.0.0';
        type("MCS.NAV.PcEftPos.EFTPOSData"; "EFTPOSData") { }
        type("MCS.NAV.PcEftPos.EFTPOS"; "EFTPOS")
        {

        }
        //type("MCS.NAV.PcEftPos.STAWrapper"; STAWrapper) { }
    }
    assembly("EFTTCPIP")
    {
        Culture = 'neutral';
        Version = '1.0.0.0';
        type("EFTTCPIP.LSFunctionsV2"; "EFT_TCPIP")
        {

        }
        type("EFTTCPIP.Model_LS.EFTDataLS"; "EFTDataLS") { }
    }
}
