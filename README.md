# dynamic-srm-hrtf

MATLAB code for measuring HRTFs and simulating **dynamic Spatial Release from Masking (SRM)** under different head‑movement conditions (world‑fixed vs head‑locked) using the Jelfs2011 model.

## Folder structure
```text
Programs/
├── HRTF/
│   ├── hrtf_final_windowed.m %measure + window HRIRs and estimate HRTFs
│   ├── hrtf_sofa.m %convert measured HRTFs to SOFA format
│   ├── setfig.m %figure sizing/styling
│   └── win_hrtf.sofa %sample SOFA file (windowed HRTFs)
├── KEMAR_SRM/
│   ├── Test_Jelf2011_Mk3.m % SRM of different targets at various head orientation (KEMAR)
│   ├── Test_Jelf2011_Mk3_avg.m % Averaged SRM between world-fixed and headlocked condition
└── SRM_for_HRTFs/
    ├── kemar_avil_hrtf_vs_win_hrtf.m %compare KEMAR, HATS, and individual HRTFs
    └── kemar_avil_hrtf_vs_win_hrtf_data.mat %workspace saved from last run

## Dependencies

- MATLAB (tested with R2024/25)
- AMT toolbox 1.6.0 (for `jelfs2011` and related functions)
- SOFA support for MATLAB (for HRTF import/export)

## Typical workflow

1. **Measure HRTFs**

   Run:
  cd('Programs/HRTF')
  hrtf_final_windowed % sweep playback, IR estimation, time windowing
  hrtf_sofa % convert irEstimate to win_hrtf.sofa

2. **KEMAR SRM simulations**
  cd('../KEMAR_SRM')
  Test_Jelf2011_Mk3 % per‑target SRM vs head orientation
  Test_Jelf2011_Mk3_avg % averaged SRM plots

3. **SRM with different HRTFs**
   cd('../SRM_for_HRTFs')
  kemar_avil_hrtf_vs_win_hrtf
