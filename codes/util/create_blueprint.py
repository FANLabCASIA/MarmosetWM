#!/usr/bin/env fslpython

# Multiply a bunch of fdt_paths with a matrix2 to form a blueprint
#
# Author: Saad Jbabdi <saad@fmrib.ox.ac.uk>
#
# Copyright (C) 2020 University of Oxford
#   Part of FSL - FMRIB's Software Library
#   http://www.fmrib.ox.ac.uk/fsl
#   fsl@fmrib.ox.ac.uk
#
#   Developed at FMRIB (Oxford Centre for Functional Magnetic Resonance
#   Imaging of the Brain), Department of Clinical Neurology, Oxford
#   University, Oxford, UK
#
#
#   LICENCE
#
#   FMRIB Software Library, Release 6.0 (c) 2018, The University of
#   Oxford (the "Software")
#
#   The Software remains the property of the Oxford University Innovation
#   ("the University").
#
#   The Software is distributed "AS IS" under this Licence solely for
#   non-commercial use in the hope that it will be useful, but in order
#   that the University as a charitable foundation protects its assets for
#   the benefit of its educational and research purposes, the University
#   makes clear that no condition is made or to be implied, nor is any
#   warranty given or to be implied, as to the accuracy of the Software,
#   or that it will be suitable for any particular purpose or for use
#   under any specific conditions. Furthermore, the University disclaims
#   all responsibility for the use which is made of the Software. It
#   further disclaims any liability for the outcomes arising from using
#   the Software.
#
#   The Licensee agrees to indemnify the University and hold the
#   University harmless from and against any and all claims, damages and
#   liabilities asserted by third parties (including claims for
#   negligence) which arise directly or indirectly from the use of the
#   Software or the sale of any products based on the Software.
#
#   No part of the Software may be reproduced, modified, transmitted or
#   transferred in any form or by any means, electronic or mechanical,
#   without the express permission of the University. The permission of
#   the University is not required if the said reproduction, modification,
#   transmission or transference is done without financial return, the
#   conditions of this Licence are imposed upon the receiver of the
#   product, and all original and amended source code is included in any
#   transmitted product. You may be held legally responsible for any
#   copyright infringement that is caused or encouraged by your failure to
#   abide by these terms and conditions.
#
#   You are not permitted under this Licence to use this Software
#   commercially. Use for which any financial return is received shall be
#   defined as commercial use, and includes (1) integration of all or part
#   of the source code or the Software into a product for sale or license
#   by or on behalf of Licensee to third parties or (2) use of the
#   Software or any derivative of it for research with the final aim of
#   developing software products for sale or license to a third party or
#   (3) use of the Software or any derivative of it for research with the
#   final aim of developing non-software products for sale or license to a
#   third party, or (4) use of the Software to provide any service to an
#   external organisation for which payment is received. If you are
#   interested in using the Software commercially, please contact Oxford
#   University Innovation ("OUI"), the technology transfer company of the
#   University, to negotiate a licence. Contact details are:
#   fsl@innovation.ox.ac.uk quoting Reference Project 9564, FSL.

import numpy as np
import sys,os,glob
import scipy.sparse as sps

# Image stuff
import nibabel as nib
from nibabel import cifti2
from fsl.data.image import Image
from fsl.data.cifti import cifti2_axes
from fsl.data.cifti import Cifti

xtract_folder = sys.argv[1]
ptx_folder    = sys.argv[2] # the ptx_folder(s)- if 2, comma separated
seed_path      = sys.argv[3] # the seed mask(s) - if 2, comma separated
roi_path  = sys.argv[4] # using the medial wall as a mask(s)? - if 2, comma separated
tracts        = sys.argv[5]
distnorm      = int(sys.argv[6])
savetxt       = int(sys.argv[7]) # cii (0) or txt (1)?
prefix        = sys.argv[8]

# split the arguments here
ptx_folder=ptx_folder.split(",")
seed_path=seed_path.split(",")
tracts=tracts.split(",")
if prefix != "x":
    prefix=f'{prefix}_'
else:
    prefix=''

if len(ptx_folder) == 2:
    print('Building whole-brain connectivity blueprint')
else:
    print('Building single hemisphere connectivity blueprint')

# load the seed ROIs
seed = []
for p in seed_path:
    ### CHANGED BY YUFAN WANG
    # temp = nib.load(p).darrays[0].data != 0
    temp = nib.load(p).darrays[0].data
    temp[np.where(temp==0)] = 0.0001
    temp = temp != 0
    ### CHANGED BY YUFAN WANG
    seed.append(temp[:,0])

# if using medial wall, load the masks
if roi_path != "x":
    roi_path=roi_path.split(",")
    roi = []
    for p in roi_path:
        temp = nib.load(p).darrays[0].data
        if np.unique(temp).shape[0] > 2:
            print('Warning!! Medial wall mask is not binary.')
            print('Binarising...')
            temp = (temp > 0)*1
        roi.append(temp)
    # and stack
    if len(ptx_folder) == 2:
        roi = np.concatenate((roi[0],roi[1]))
    else:
        roi = roi[0]

print('')
print('')

# mask and lut are equal across hemispheres, so only need 1
maskfile = os.path.join(ptx_folder[0],'lookup_tractspace_fdt_matrix2')
mask     = Image(maskfile)
lut      = Image(os.path.join(ptx_folder[0],'lookup_tractspace_fdt_matrix2.nii.gz'))
lut      = lut.data[mask.data>0]-1


# Get num voxels in mask and num tracts
nvoxels = np.sum(mask.data>0)
ntracts = len(tracts)

print(f'Generating blueprint with {ntracts} tracts')
# Collect tracts
tracts_mat = np.zeros( (nvoxels, ntracts) )
print('Reading tracts...')
trm=[]
for idx,t in enumerate(tracts):
    t = os.path.join(xtract_folder,f'{t}.nii.gz')
    if os.path.exists(t):
        tract = Image(t)
        tracts_mat[lut,idx] = tract[mask.data>0]
    else:
        print(f'Could not find {tracts[idx]}. Skipping... (will remove from final output)')
        trm.append(int(idx))

# remove missing tract columns
tracts_mat = np.delete(tracts_mat, [trm], 1)
for i in trm:
    tracts.pop(i)

def normalise(M):
    D = np.sum(M,axis=1)
    D[D==0] = 1
    M = M / D[:,None]
    return M

def load_fdt(fdt_path):
    print('Reading tractography matrix. This may take a few minutes...')
    mat         = np.loadtxt(fdt_path)
    data        = mat[:-1, -1]
    rows        = np.array(mat[:-1, 0]-1, dtype=int)
    cols        = np.array(mat[:-1, 1]-1, dtype=int)
    nrows,ncols = int(mat[-1, 0]), int(mat[-1,1])
    M           = sps.csc_matrix((data, (rows,cols)), shape=(nrows,ncols)).toarray()
    M           = normalise(M)
    return M

# Open matrix2 file
M = []
for p in ptx_folder:
    M.append(load_fdt(os.path.join(p, "fdt_matrix2.dot")))

if len(ptx_folder) == 2:
    print('Stacking hemispheres...')
    M = np.concatenate((M[0], M[1]))
else:
    M = M[0]

print(f'Tractography matrix dimensions: {M.shape[0]} vertices, {M.shape[1]} voxels')

# Create blueprint
print('Calculating blueprint...')
BP = M@tracts_mat
# BP = normalise(BP)

# Convert to full cortex structure here (i.e. add in empty medial wall)
if roi_path != "x":
    # and stack
    if len(ptx_folder) == 2:
        seed_temp = np.concatenate((seed[0],seed[1]))
    else:
        seed_temp = seed[0]
    full_BP = np.zeros([np.shape(seed_temp)[0], np.shape(BP)[1]])
    full_BP[roi == 1, :] = BP
    BP = full_BP

# function to find which hemisphere/cifti structure we're working with
def get_structure(p):
    f = open(p, 'r')
    text = f.read()
    text = text.split('Cortex',1)[1]
    cstruct = text.split(']]></Value>',1)[0]
    return cstruct

# out_folder = os.path.dirname(os.path.dirname(ptx_folder[0]))
# out_folder = os.path.dirname(ptx_folder[0])
out_folder = os.path.dirname(xtract_folder)
if savetxt == 1:
    if len(ptx_folder) == 1:
        cstruct = get_structure(seed_path[0])
        if cstruct == 'Left':
            side='L'
        else:
            side='R'

        new_fname = os.path.join(out_folder, f'{prefix}BP.{side}.txt')
        np.savetxt(new_fname, BP)
        new_fname_tord = os.path.join(out_folder, f'{prefix}tract_order.{side}.txt')
        np.savetxt(new_fname_tord, tracts, fmt="%s")
    elif len(ptx_folder) == 2:
        new_fname = os.path.join(out_folder, f'{prefix}BP.LR.txt')
        np.savetxt(new_fname, BP)
        new_fname_tord = os.path.join(out_folder, f'{prefix}tract_order.LR.txt')
        np.savetxt(new_fname_tord, tracts, fmt="%s")
else:
    # set up cifti brain model axes
    if len(ptx_folder) == 1:
        cstruct = get_structure(seed_path[0])
        if cstruct == 'Left':
            side='L'
        else:
            side='R'
        bm        = cifti2_axes.BrainModelAxis.from_mask(seed[0], name=f'Cortex{cstruct}')
        new_fname = os.path.join(out_folder, f'{prefix}BP.{side}.dscalar.nii')
    elif len(ptx_folder) == 2:
        bm_l      = cifti2_axes.BrainModelAxis.from_mask(seed[0], name=f'CortexLeft')
        bm_r      = cifti2_axes.BrainModelAxis.from_mask(seed[1], name=f'CortexRight')
        bm        = bm_l + bm_r
        new_fname = os.path.join(out_folder, f'{prefix}BP.LR.dscalar.nii')
    # save cifti
    sc        = cifti2_axes.ScalarAxis(tracts)
    hdr       = cifti2.Cifti2Header.from_axes((sc, bm))
    img       = cifti2.Cifti2Image(BP.T, hdr)
    nib.save(img, new_fname)

print(f'Saved: {new_fname}')
print('')
