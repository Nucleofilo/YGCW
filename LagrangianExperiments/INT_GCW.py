### SCRIPT to integrate particles backwards in time from initial positions
### given by GCW data (mat files) using NEMO model outputs (netcdf files)
### The script reads a list of mat files and a list of NEMO files
### The script needs two command line arguments: initial and final experiment numbers
##
##  Example of command line to run the script:
##  python INT_GCW.py 0 10 > log_INT_GCW_0_10.txt &
##  This command runs the script for experiments 1 to 10 (0 to 9 in python indexing)
##  The log file is saved in log_INT_GCW_0_10.txt 
##   
### The script creates a directory NEW_PARTS with the zarr files for each day and experiment,
### it creates a netcdf file for each day and alsi creates a netcdf file with all particles for each experiment
### The script uses parcels 2.4.0
###
### Author: Alejandro Dominguez-Guadarrama
### Contact: adomingu@cicese.edu.mx
### Date: June 2024 (last update 2025-08-27)
### Version 2.0
###
### Note that the script assumes that the mat files are in a directory called EventosGCWNemo
### and that the list of mat files is in a file called listmats.txt
### Note that the script assumes that the list of NEMO files is in a file called listNemos.txt
###
###
### Before running the script you need to load python PARCELS environment e.g. mamba activate parcels
### 


# IMPORT standard python modules 
from datetime import timedelta as delta
import datetime as dt
from glob import glob
import numpy as np
import matplotlib.pyplot as plt
import xarray as xr
import os
import scipy.io as sio
import sys
from os import path


# IMPORT main parcels modules
from parcels import (
    AdvectionRK4_3D,
    FieldSet,
    JITParticle,
    ParticleSet,
    #XarrayDecodedFilter,
    logger,
)


# CREATE CHECK function to delete particles out of bounds
# IMPORT StatusCode to check particle status
def CheckOutOfBounds(particle, fieldset, time):
    if particle.state == StatusCode.ErrorOutOfBounds:
        particle.delete()

# CREATE SAMPLING function to get temperature and salinity
def SampleT(particle, fieldset, time):
    particle.T = fieldset.T[time, particle.depth, particle.lat, particle.lon]
    particle.S = fieldset.S[time, particle.depth, particle.lat, particle.lon]

# READ command line arguments for initial and final experiment numbers
print(sys.argv[1])
idmi=int(sys.argv[1]) # initial experiment number
idmf=int(sys.argv[2]) # final experiment number 
print('Initial experiment number: '+str(idmi))
print('Final experiment number: '+str(idmf))

# Note that all variables need the same dimensions in a C-Grid
c_grid_dimensions = {
    "lon": "glamf",
    "lat": "gphif",
    "depth": "depthw",
    "time": "time_counter",
}
dimensions = {
    "U": c_grid_dimensions,
    "V": c_grid_dimensions,
    "W": c_grid_dimensions,
    "T": c_grid_dimensions,
    "S": c_grid_dimensions,
}



# GET datetimes for inital and final dates on mat files
#!ls EventosGCWNemo/*.mat >listmats.txt
mfiles=open('listmats.txt').readlines()

dism=[mfi.replace('EventosGCWNemo/','').split('_')[1] for mfi in mfiles]
dfsm=[mfi.replace('EventosGCWNemo/','').split('_')[2].replace('.mat','')[:-1] for mfi in mfiles]

dtsmati=[dt.datetime.strptime(di, '%d-%b-%Y') for di in dism] # INITIAL dates from mat files
dtsmatf=[dt.datetime.strptime(df, '%d-%b-%Y') for df in dfsm] # FINAL dates from mat files

nms=len(mfiles) # NUMBER of matlab files
#for ii in range(nms):

ncfiles=open('listNemos.txt').readlines() # LIST of NEMO files including the path to the files
ncfs=np.array(ncfiles);
print(ncfs[35:38])
# EXTRACT INITIAL dates from NEMO files
dis=[nci.split('_')[2] for nci in ncfiles]
dfs=[nci.split('_')[3] for nci in ncfiles]
print(dis[35:38])

yrnci=[int(di[0:4]) for di in dis]; yrnci=np.array(yrnci)
mnci=[int(di[4:6]) for di in dis];  mnci=np.array(mnci)
dynci=[int(di[6:8]) for di in dis];  dynci=np.array(dynci)

# EXTRACT FINAL dates from NEMO files
yrncf=[int(df[0:4]) for df in dfs];  yrncf=np.array(yrncf)
mncf=[int(df[4:6]) for df in dfs];   mncf=np.array(mncf)
dyncf=[int(df[6:8]) for df in dfs];  dynci=np.array(dyncf)

if idmf>0:
    nms=idmf

# LOOP over experiments to process (mat files)
for ii in range(idmi,nms):
    exp='EXP'+str(ii+1).zfill(2)
    print("PROCESSING experiment "+ exp)
    fmi=mfiles[ii][:-1]
    print('PROCESING mat file:' +fmi)
    ds=sio.loadmat(fmi)
    gcp=ds['gcp']
    time=ds['tien'][-1]
   
    ntbw=20
    

    #SELECT inital and final dates mat file
    di=dtsmati[ii]; df=dtsmatf[ii]
    print((di,df))
    y=di.year; m=di.month; d=di.day; y2=df.year; m2=df.month; d2=df.day
    print('Initial date: '+str(di)+' Final date: '+str(df))

    # SELECT NEMO files covering the dates for integration
    if y==y2:  # SAME year for initial and final dates
       print('DATA in the same year '+str(y)) 
       cfs=(yrnci==di.year)*(mnci>=di.month)*(mnci<=df.month) # BOOLEAN conditions selecting year and months for dates
       idxfs=np.where(cfs)[0]  # FIND indices for NEMO files covering the dates
       idxfs = np.append( idxfs[0]-1,idxfs)
    elif y2>y: # TWO consecutive years for initial and final dates
        print('DATA in two consecutive years: '+ str(y)+' '+str(y2))
        cfs=(yrnci==di.year)*(mnci>=di.month)
        idxfs=np.where(cfs)[0]
        idxfs = np.append( idxfs[0]-1,idxfs)
        cfs2=(yrnci==df.year)*(mnci<=df.month)
        idxfs2=np.where(cfs2)[0]
        idxfs = np.append(idxfs,idxfs2)
    print('INDICES to use')
    print(idxfs)
    print('')

    #idxfs=np.where(cfs)[0]  # FIND indices for NEMO files covering the dates
    #idxfs = np.append( idxfs[0]-1,idxfs) 
       
    #filesNC2link=ncfs[idx]
    # CREATE list of files to use for integration (ufiles,vfiles,wfiles,tfiles)
    ufiles=[]; vfiles=[]; wfiles=[]; tfiles=[];
    for fni in ncfs[idxfs]:
        fnt=fni[:-1]
        tfiles.append(fnt);
        #ntmp=fni.replace('G108','TEMP')
        #txtlnt='ln -s '+fni+' '+fntmp
        ufiles.append(fnt.replace('T.nc','U.nc'));
        vfiles.append(fnt.replace('T.nc','V.nc'));
        wfiles.append(fnt.replace('T.nc','W.nc'));
    print(ufiles)
    mesh_mask = "mesh_mask.nc"

    # CREATE the fieldset
    filenames = {
        "U": {"lon": mesh_mask, "lat": mesh_mask, "depth": wfiles[0], "data": ufiles},
        "V": {"lon": mesh_mask, "lat": mesh_mask, "depth": wfiles[0], "data": vfiles},
        "W": {"lon": mesh_mask, "lat": mesh_mask, "depth": wfiles[0], "data": wfiles},
        "T": {"lon": mesh_mask, "lat": mesh_mask, "depth": wfiles[0], "data": tfiles},
        "S": {"lon": mesh_mask, "lat": mesh_mask, "depth": wfiles[0], "data": tfiles},
        }

    variables = {"U": "uoce", "V": "voce", "W": "woce","T": "toce","S": "soce"}


    # Note that all variables need the same dimensions in a C-Grid
    c_grid_dimensions = {
        "lon": "glamf",
        "lat": "gphif",
        "depth": "depthw",
        "time": "time_counter",
    }
    dimensions = {
        "U": c_grid_dimensions,
        "V": c_grid_dimensions,
        "W": c_grid_dimensions,
        "T": c_grid_dimensions,
        "S": c_grid_dimensions,
    }

    fieldset = FieldSet.from_nemo(filenames, variables, dimensions)

    SampleParticle = JITParticle.add_variable("T")
    SampleParticle = SampleParticle.add_variable("S")
#    [
#        variables("T", dtype=np.float32, initial=np.nan),
#        variables("S", dtype=np.float32, initial=np.nan),
#    ]
#    )




    #print(fieldset)
    # NOW lets construct the particle coordinates from mat files
    ndys=gcp.size; print('Total number of days to compute: '+str(ndys)) 
    time=ds['tien'][-1]  # Time vector from mat file days since 1900-01-01
    print(yrnci[idxfs])
    print(mnci[idxfs])
    print(dynci[idxfs])
    filenc=ufiles[0]
    fnss=filenc.split('_')[2]

    print(filenc)
    print(idxfs[0])
    #ync=int(di[0:4]) ; mnc= mnci[idxfs[0]]; dync=dynci[idxfs[0]];
    ync=int(fnss[0:4]) ; mnc=int(fnss[4:6]); dync=int(fnss[6:8]);
    dtref=dt.datetime(ync,mnc,dync,12,0,0); print(dtref)
    #x = input('Enter to continue:')
    dti_ref=(di-dtref).days # Difference between di and dref form netcdf files
    refdy=time[0]-dti_ref     # REFERENCE date for correcting mat dates
    dysini=time-refdy    
    print("INITIAL days ")
    print(dysini)

    ntfw=20
    ntbw=20
    #ndys=2


    for dy in range(ndys):
        dyii=dysini[dy]; 

        print("Initial day: "); print(dyii); print('')
        xs=gcp[0,dy]['x']; #print(xs)
        ys=gcp[0,dy]['y']
        zs=-gcp[0,dy]['z']
        ts=zs*0+(dyii+0.5)*86400.

        if xs.size>0: # ONLY if there are particles to simulate
            print('Number of particles to simulate: '+str(xs.size))
            # CREATE the particle set   
            pset=ParticleSet(
                fieldset=fieldset,
                pclass=SampleParticle,
                lon=xs,
                lat=ys,
                depth=zs,
                #time=lat2*0,
                time=ts,
                lonlatdepth_dtype= np.float64,
                )
            #print(pset)
            pset.populate_indices()
            kernels=pset.Kernel([AdvectionRK4_3D, SampleT, CheckOutOfBounds]) # ADD the sampling and check kernels
            # DEFINE output file name   
            nf=str(dyii).zfill(3)
            fnamz='NEW_PARTS/'+exp+'_'+nf+'.zarr'
            print(fnamz)
            flagE=os.path.exists(fnamz) 
        # create output file
            output_file = pset.ParticleFile(name=fnamz, outputdt=delta(hours=3))

            # CHECK if file already exists
            flagE=os.path.exists(fnamz)
            if flagE:
                print('File Already exists')
            else:
                print('RUNNING backwards')
                pset.execute(kernels,
                    runtime=delta(days=ntbw),
                    dt=-delta(minutes=20),
                    output_file=output_file,
                    )
            ncfile='GCW_'+exp+'_dy'+nf+'.nc'
            print(ncfile)
            ds_out = xr.open_zarr(fnamz)
            ds_out.to_netcdf(ncfile)
            output_file.close()
            pset.delete()
    print('FINISHED all days for experiment '+exp)
    print('CONCATENATING all zarr files for the experiment '+exp)
    print(' ')

    # CREATE directory for new particles if it does not exist
    if not os.path.exists('NEW_PARTS'):
        os.makedirs('NEW_PARTS')    
   
    # CONCATENATE all zarr files for the experiment
    files = glob(path.join('NEW_PARTS', exp+"*"))
    dsfs = xr.concat(
        [xr.open_zarr(f) for f in files],
        dim="trajectory",
        compat="no_conflicts",
        coords="minimal",
    )
    dsfs.to_netcdf('GCW_NEW_PARTS_'+exp+'.nc')
