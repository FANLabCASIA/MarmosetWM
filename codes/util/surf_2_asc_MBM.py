import numpy as np
import os
from nilearn import surface 
import scipy.sparse as sp
import pandas as pd


rootdir = '/n02dat01/users/yfwang/Data/marmoset_MBM/'
with open('/n02dat01/users/yfwang/Data/marmoset_MBM/marmoset_MBM_list.txt', 'r') as f:
    sublist = [str(name).strip() for name in f.readlines()]

datapath = '/n02dat01/users/yfwang/MarmosetWM/support_data/surf'

# ######
# # left
# ######
# hemi = 'lh'

# for sub in sublist:
#     print(f'********** {sub} **********')
#     subdir = rootdir + sub
#     if not os.path.exists(f'{subdir}/surf'):
#         os.mkdir(f'{subdir}/surf')
    
#     for surf in ['white', 'pial']:

#         ###################
#         # surfFS asc to csv
#         ###################
#         data = np.loadtxt(f'{datapath}/surfFS.{hemi}.{surf}.asc', skiprows=2)
#         area = data[37974:37974+75944]
#         data = data[:37974]
#         data[:, :2] = -data[:, :2]
#         data = pd.DataFrame(data, columns=['x', 'y', 'z', 'label'])
#         data.to_csv(f'{datapath}/surfFS_{hemi}_{surf}.csv', index=False)      

#         #########################
#         # register to individuals
#         #########################
#         # ants_mat_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat'
#         # ants_warp_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz'
#         ants_mat_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat'
#         ants_warp_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz'
        
#         trans_template_path = f'{datapath}/surfFS_{hemi}_{surf}.csv'
#         trans_DTI_path = f'{subdir}/surf/surfFS_{hemi}_{surf}.csv'

#         # command = '/share/soft/ants/antsApplyTransformsToPoints -d 3 -i {} -o {} -t [{}, 1] -t {}'.format(trans_template_path, trans_DTI_path, ants_mat_path, ants_warp_path)
#         command = '/share/soft/ants/antsApplyTransformsToPoints -d 3 -i {} -o {} -t {} -t {}'.format(trans_template_path, trans_DTI_path, ants_warp_path, ants_mat_path)
#         print(command)
#         n = os.system(command)
#         print(n)

#         ###########
#         # write asc
#         ###########
#         data = pd.read_csv(trans_DTI_path)
#         data = data.values
#         header1 = '#!ascii from CsvMesh'
#         header2 = '37974 75944'
#         with open(f'{subdir}/surf/DTI_{hemi}_{surf}.asc', 'w') as f:
#             f.write(header1)
#             f.write('\r\n')
#             f.write(header2)
#             f.write('\r\n')
#             for i in range(len(data)):
#                 f.write(str(-data[i,0].round(3))+' '+str(-data[i,1].round(3))+' '+str(data[i,2].round(3))+' '+str(data[i,3]))
#                 f.write('\r\n')
#             for ii in range(len(area)):
#                 f.write(str(int(area[ii,0]))+' '+str(int(area[ii,1]))+' '+str(int(area[ii,2]))+' '+'0')
#                 f.write('\r\n')

#         ############
#         # write surf
#         ############
#         asc_path = f'{subdir}/surf/DTI_{hemi}_{surf}.asc'
#         gii_path = f'{subdir}/surf/DTI_{hemi}_{surf}.surf.gii'
#         roi_path = f'{datapath}/surfFS.{hemi}.atlasroi.shape.gii'

#         command = 'surf2surf -i {} -o {} --values={}'.format(asc_path, gii_path, roi_path)
#         print(command)
#         n = os.system(command)
#         print(n)


# #######
# # right
# #######
# hemi = 'rh'

# for sub in sublist:
#     print(f'********** {sub} **********')
#     subdir = rootdir + sub
#     if not os.path.exists(f'{subdir}/surf'):
#         os.mkdir(f'{subdir}/surf')
    
#     for surf in ['white', 'pial']:

#         ###################
#         # surfFS asc to csv
#         ###################
#         data = np.loadtxt(f'{datapath}/surfFS.{hemi}.{surf}.asc', skiprows=2)
#         area = data[38094:38094+76184]
#         data = data[:38094]
#         data[:, :2] = -data[:, :2]
#         data = pd.DataFrame(data, columns=['x', 'y', 'z', 'label'])
#         data.to_csv(f'{datapath}/surfFS_{hemi}_{surf}.csv', index=False)      

#         #########################
#         # register to individuals
#         #########################
#         # ants_mat_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat'
#         # ants_warp_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz'
#         ants_mat_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat'
#         ants_warp_path = f'{subdir}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz'
        
#         trans_template_path = f'{datapath}/surfFS_{hemi}_{surf}.csv'
#         trans_DTI_path = f'{subdir}/surf/surfFS_{hemi}_{surf}.csv'

#         # command = '/share/soft/ants/antsApplyTransformsToPoints -d 3 -i {} -o {} -t [{}, 1] -t {}'.format(trans_template_path, trans_DTI_path, ants_mat_path, ants_warp_path)
#         command = '/share/soft/ants/antsApplyTransformsToPoints -d 3 -i {} -o {} -t {} -t {}'.format(trans_template_path, trans_DTI_path, ants_warp_path, ants_mat_path)
#         print(command)
#         n = os.system(command)
#         print(n)

#         ###########
#         # write asc
#         ###########
#         data = pd.read_csv(trans_DTI_path)
#         data = data.values
#         header1 = '#!ascii from CsvMesh'
#         header2 = '38094 76184'
#         with open(f'{subdir}/surf/DTI_{hemi}_{surf}.asc', 'w') as f:
#             f.write(header1)
#             f.write('\r\n')
#             f.write(header2)
#             f.write('\r\n')
#             for i in range(len(data)):
#                 f.write(str(-data[i,0].round(3))+' '+str(-data[i,1].round(3))+' '+str(data[i,2].round(3))+' '+str(data[i,3]))
#                 f.write('\r\n')
#             for ii in range(len(area)):
#                 f.write(str(int(area[ii,0]))+' '+str(int(area[ii,1]))+' '+str(int(area[ii,2]))+' '+'0')
#                 f.write('\r\n')

#         ############
#         # write surf
#         ############
#         asc_path = f'{subdir}/surf/DTI_{hemi}_{surf}.asc'
#         gii_path = f'{subdir}/surf/DTI_{hemi}_{surf}.surf.gii'
#         roi_path = f'{datapath}/surfFS.{hemi}.atlasroi.shape.gii'

#         command = 'surf2surf -i {} -o {} --values={}'.format(asc_path, gii_path, roi_path)
#         print(command)
#         n = os.system(command)
#         print(n)


###############
# set structure
###############

for sub in sublist:
    print(f'********** {sub} **********')
    subdir = rootdir + sub

    for surf in ['white', 'pial']:

        gii_path = f'{subdir}/surf/DTI_lh_{surf}.surf.gii'
        command = 'wb_command -set-structure {} CORTEX_LEFT'.format(gii_path)
        print(command)
        n = os.system(command)
        print(n)

        gii_path = f'{subdir}/surf/DTI_rh_{surf}.surf.gii'
        command = 'wb_command -set-structure {} CORTEX_RIGHT'.format(gii_path)
        print(command)
        n = os.system(command)
        print(n)

# #######################
# # write stop and wtstop
# #######################

# for sub in sublist:
#     print(f'********** {sub} **********')
#     subdir = rootdir + sub
#     if os.path.exists(f'{subdir}/surf/stop_ants'):
#         os.remove(f'{subdir}/surf/stop_ants')
#     if os.path.exists(f'{subdir}/surf/wtstop_ants'):
#         os.remove(f'{subdir}/surf/wtstop_ants')
    
#     for hemi in ['lh','rh']:
#         savepath = '{}/surf/DTI_{}_pial.asc'.format(subdir, hemi)
#         os.system('echo {}>>{}/surf/stop_ants'.format(savepath, subdir))
#         savepath = '{}/surf/DTI_{}_white.asc'.format(subdir, hemi)
#         os.system('echo {}>>{}/surf/wtstop_ants'.format(savepath, subdir))
