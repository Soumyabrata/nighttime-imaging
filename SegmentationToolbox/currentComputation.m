classdef currentComputation < handle
    %CURRENTCOMPUTATION Contains all the values and methods to create a
    % superpixel segmentation. The methods are invoked through the GUI for
    % executing the various tasks.
    
    % Convention for storing labels :
    % 0 : no label assigned
    % 1 : clear sky
    % 2 : Puffy cloud
    % 3 : Thick cloud
    % 4 : Thin cloud
    % 5 : Veil cloud
    % 42 : Specularities
    % 43 : Occlusions
    
    properties
        originalImage % Stores the original image in RGB
        originalImageLAB % Stores the original image in LAB
        imageName % Name of the image
        
        segmentations % Stores the various segmentations
        currentSegmInd % Int. indexing the current segmentation
        initialSegm % Initial foreground/background segmentation
        
        labels % Stores the various labels
        
        divideBy % Region size parameter for SLIC
        compactness % Compactness factor
        
        dispBorders % Bool indicating if borders are displayed
        dispLabels % Bool indicating if labels are displayed
        
        fig % The figure in which to display the image
        selectedIdx % Index of the selected element - -1 : no selection
        
        applyLabelChange % Boolean indicating if label change should be done
        selectedLabel % Indicates with label is selected in the GUI
        
        displayedFig % Figure currently displayed
        
    end
    
    methods
        
        % Constructor function
        function obj = currentComputation(image, divideBy, compactness, dispBorders, ...
                dispLabels, applyLabelChange, selectedLabel, initialSegm, imageName)
            
            addpath('SLIC');
            
            % To regain the waitbar, we need to uncomment h=waitbar...,
            % 1/3...2/3...and delete(h).
            %h = waitbar(0, 'Computing SLIC segmentation...');
            
            obj.originalImage = image;
            obj.displayedFig = zeros(size(image));
            obj.originalImageLAB = applycform(image, makecform('srgb2lab'));
            obj.divideBy = divideBy;
            obj.compactness = compactness;
            obj.initialSegm = initialSegm;
            obj.imageName = imageName;
            
            if obj.divideBy < 4
                divideByLocal = 4;
            else
                divideByLocal = obj.divideBy;
            end
            if(~isnan(initialSegm))
                regionSize = (size(obj.originalImage, 1) * size(obj.originalImage, 2) - nnz(initialSegm)) / divideByLocal;
            else
                regionSize = size(obj.originalImage, 1) * size(obj.originalImage, 2) / divideByLocal;
            end
            obj.segmentations = epfl_slic(obj.originalImage, regionSize, obj.compactness);
            
            obj.labels = zeros(size(obj.segmentations));
            obj.currentSegmInd = 1;
            
            if(~isnan(initialSegm))
                maxSegmInd = max(obj.segmentations(:));
                obj.segmentations(initialSegm ~= 0) = maxSegmInd + 1;
                obj.labels(initialSegm ~= 0) = 43;
            end
            %waitbar(1/3, h, 'Splitting disconnected superpixels...');
            obj.segmentations = obj.splitDisconnectedSuperpixels(obj.segmentations);
            %waitbar(2/3, h, 'Merging too small superpixels...');
            obj.segmentations = obj.mergeSmallSuperpixels(obj.segmentations, obj.labels, regionSize);
            
            obj.dispBorders = dispBorders;
            obj.dispLabels = dispLabels;
            
            obj.applyLabelChange = applyLabelChange;
            obj.selectedLabel = selectedLabel;
            
            % Borders on the image.
            % Please uncomment obj.fig, set... and obj.displayImage
            obj.fig = figure('Name', 'SLIC superpixels segmentation result');
            set(obj.fig, 'WindowButtonDownFcn', @obj.selectionCallback)
            obj.selectedIdx = -1;
            
            
            obj.displayImage;
            
            
            
            %delete(h);
            
        end
        
        % Regenerate the display of the current image
        function displayImage(obj)
            
            img = obj.originalImage;
            
            if obj.dispLabels
                thisLabels = obj.labels(:,:,obj.currentSegmInd);
                labelClearIdx = find(thisLabels == 1);
                labelPuffyIdx = find(thisLabels == 2);
                labelThickIdx = find(thisLabels == 3);
                labelThinIdx = find(thisLabels == 4);
                labelVeilIdx = find(thisLabels == 5);
                labelSpecIdx = find(thisLabels == 42);
                labelOcclIdx = find(thisLabels == 43);
                
                imgR = img(:,:,1); imgG = img(:,:,2); imgB = img(:,:,3);
                imgBW = rgb2gray(img);
                
                % We avoid extremely dark and white areas
                imgBW = double(imgBW) / 255 * 150 + 100;
                
                imgBW = double(imgBW) / 255;
                
                % Clear sky : 255,0,0
                imgR(labelClearIdx) = 255*imgBW(labelClearIdx);
                imgG(labelClearIdx) = 0*imgBW(labelClearIdx);
                imgB(labelClearIdx) = 0*imgBW(labelClearIdx);
                
                % Puffy clouds : 0,255,0
                imgR(labelPuffyIdx) = 0*imgBW(labelPuffyIdx);
                imgG(labelPuffyIdx) = 255*imgBW(labelPuffyIdx);
                imgB(labelPuffyIdx) = 0*imgBW(labelPuffyIdx);
                
                % Thick clouds : 0,0,255
                imgR(labelThickIdx) = 0*imgBW(labelThickIdx);
                imgG(labelThickIdx) = 0*imgBW(labelThickIdx);
                imgB(labelThickIdx) = 255*imgBW(labelThickIdx);
                
                % Thin clouds : 255,255,0
                imgR(labelThinIdx) = 255*imgBW(labelThinIdx);
                imgG(labelThinIdx) = 255*imgBW(labelThinIdx);
                imgB(labelThinIdx) = 0*imgBW(labelThinIdx);
                
                % Veil clouds : 255,0,255
                imgR(labelVeilIdx) = 255*imgBW(labelVeilIdx);
                imgG(labelVeilIdx) = 0*imgBW(labelVeilIdx);
                imgB(labelVeilIdx) = 255*imgBW(labelVeilIdx);
                
                % Specularities : 0,255,255
                imgR(labelSpecIdx) = 0*imgBW(labelSpecIdx);
                imgG(labelSpecIdx) = 255*imgBW(labelSpecIdx);
                imgB(labelSpecIdx) = 255*imgBW(labelSpecIdx);
                
                % Occlusions : 255,128,0
                imgR(labelOcclIdx) = 255*imgBW(labelOcclIdx);
                imgG(labelOcclIdx) = 128*imgBW(labelOcclIdx);
                imgB(labelOcclIdx) = 0*imgBW(labelOcclIdx);
                
                img(:,:,1) = uint8(imgR); img(:,:,2) = uint8(imgG); img(:,:,3) = uint8(imgB);
                
            end
            
            if obj.dispBorders
                
                % Trick for the borders : add a region all around the image
                imgSegm = obj.segmentations(:,:,obj.currentSegmInd);
                imgSegm = [-10*ones(size(imgSegm, 1),1) imgSegm -10*ones(size(imgSegm, 1),1)];
                imgSegm = [-10*ones(1,size(imgSegm, 2)) ; imgSegm ; -10*ones(1,size(imgSegm, 2))];
                [cx,cy] = gradient(double(imgSegm));
                ccc = uint8((abs(cx) + abs(cy)) == 0);
                %ccc = 1 - imdilate(1 - ccc, strel('rectangle', [2 2]));
                ccc = ccc(2:end-1, :); ccc = ccc(:, 2:end-1);
                
                imgR = img(:,:,1); imgR(ccc == 0) = 0; img(:,:,1) = imgR;
                imgG = img(:,:,2); imgG(ccc == 0) = 255; img(:,:,2) = imgG;
                imgB = img(:,:,3); imgB(ccc == 0) = 0; img(:,:,3) = imgB;
            
                if obj.selectedIdx ~= -1

                    selectedRegion = obj.segmentations(:,:,obj.currentSegmInd);
                    selectedRegion = selectedRegion == obj.selectedIdx;
                    selectedRegion = [zeros(size(selectedRegion, 1),1) selectedRegion zeros(size(selectedRegion, 1),1)];
                    selectedRegion = [zeros(1,size(selectedRegion, 2)) ; selectedRegion ; zeros(1,size(selectedRegion, 2))];

                    [cx,cy] = gradient(double(selectedRegion));
                    ccc = uint8((abs(cx) + abs(cy)) == 0);
                    %ccc = 1 - imdilate(1 - ccc, strel('rectangle', [2 2]));
                    ccc = ccc(2:end-1, :); ccc = ccc(:, 2:end-1);

                    % Selected region in red
                    imgR = img(:,:,1); imgR(ccc == 0) = 255; img(:,:,1) = imgR;
                    imgG = img(:,:,2); imgG(ccc == 0) = 0; img(:,:,2) = imgG;
                    imgB = img(:,:,3); imgB(ccc == 0) = 0; img(:,:,3) = imgB;

                end
                            
            end
            
            figure(obj.fig);
            warning('off', 'images:initSize:adjustingMag');
            imshow(img);
            warning('on', 'images:initSize:adjustingMag');
            
            % imwrite(img, 'result.png');
            
            obj.displayedFig = img;
            
        end
        
        % Compute a new segmentation on the whole image
        function newSegmentationWholeImage(obj)
            
            h = waitbar(0, 'Computing SLIC segmentation...');
            
            if obj.divideBy < 4
                divideByLocal = 4;
            else
                divideByLocal = obj.divideBy;
            end
            if(~isnan(obj.initialSegm))
                regionSize = (size(obj.originalImage, 1) * size(obj.originalImage, 2) - nnz(obj.initialSegm)) / divideByLocal;
            else
                regionSize = size(obj.originalImage, 1) * size(obj.originalImage, 2) / divideByLocal;
            end
            thisSegm = epfl_slic(obj.originalImage, regionSize, obj.compactness);
            thisLabels = zeros(size(obj.segmentations(:, :, obj.currentSegmInd)));
            
            if(~isnan(obj.initialSegm))
                maxSegmInd = max(thisSegm(:));
                thisSegm(obj.initialSegm ~= 0) = maxSegmInd + 1;
                thisLabels(obj.initialSegm ~= 0) = 43;
            end
            
            waitbar(1/3, h, 'Splitting disconnected superpixels...');
            thisSegm = obj.splitDisconnectedSuperpixels(thisSegm);
            waitbar(2/3, h, 'Merging too small superpixels...');
            thisSegm = obj.mergeSmallSuperpixels(thisSegm, thisLabels, regionSize);
            
            obj.currentSegmInd = obj.currentSegmInd + 1;
            obj.segmentations(:,:,obj.currentSegmInd) = thisSegm;
            obj.labels(:,:,obj.currentSegmInd) = thisLabels;
            
            if(size(obj.segmentations, 3) > obj.currentSegmInd)
                obj.segmentations(:,:,obj.currentSegmInd + 1:end) = [];
                obj.labels(:,:,obj.currentSegmInd + 1:end) = [];
            end
            
            obj.selectedIdx = -1;
            obj.displayImage;
            delete(h);
            
        end
        
        % Compute a new semgentation inside one superpixel (usually with smaller regionSize)
        function subsegmentSuperpixel(obj)
            
            currentSegm = obj.segmentations(:,:,obj.currentSegmInd);
            
            if obj.selectedIdx > -1 && obj.selectedIdx <= max(currentSegm(:))
                
                regionToSplit = repmat(currentSegm == obj.selectedIdx, [1,1,3]);
                regionImg = obj.originalImage .* uint8(regionToSplit);
                indFirstX = find(sum(sum(regionImg, 3), 2) ~= 0, 1, 'first');
                indLastX = find(sum(sum(regionImg, 3), 2) ~= 0, 1, 'last');
                indFirstY = find(sum(sum(regionImg, 3), 1) ~= 0, 1, 'first');
                indLastY = find(sum(sum(regionImg, 3), 1) ~= 0, 1, 'last');
                
                % toCut = regionImg(indFirstX:indLastX, indFirstY:indLastY, :);
                toCut = obj.originalImage(indFirstX:indLastX, indFirstY:indLastY, :);
                
                if obj.divideBy < 4
                    divideByLocal = 4;
                else
                    divideByLocal = obj.divideBy;
                end
                regionSize = double(nnz(currentSegm == obj.selectedIdx) / divideByLocal);
                if(regionSize - floor(regionSize) == 0)
                    regionSize = regionSize + 0.01; % The only way to really get a double....
                end
                
                segments = uint16(epfl_slic(toCut, regionSize, obj.compactness));
                segments = segments + max(currentSegm(:)) + 1;
                regionSegments = currentSegm;
                regionSegments(indFirstX:indLastX, indFirstY:indLastY) = segments;
                % One whole region with pixels outisde the image because we
                % don't want to merge with them
                regionSegments(currentSegm ~= obj.selectedIdx) = 43;
                thisLabels = 43*ones(size(regionSegments));
                thisLabels(currentSegm == obj.selectedIdx) = 0;
                regionSegments = obj.mergeSmallSuperpixels(regionSegments, thisLabels, regionSize);
                thisLabels = obj.labels(:,:,obj.currentSegmInd);
                thisLabels(currentSegm == obj.selectedIdx) = 0;
                
                segm = currentSegm;
                segm(currentSegm == obj.selectedIdx) = regionSegments(currentSegm == obj.selectedIdx);
                
                obj.currentSegmInd = obj.currentSegmInd + 1;
                obj.segmentations(:,:,obj.currentSegmInd) = segm;
                obj.labels(:,:,obj.currentSegmInd) = thisLabels;
                
                if(size(obj.segmentations, 3) > obj.currentSegmInd)
                    obj.segmentations(:,:,obj.currentSegmInd + 1:end) = [];
                    obj.labels(:,:,obj.currentSegmInd + 1:end) = [];
                end

                obj.selectedIdx = -1;
                obj.displayImage;
                
            end
            
        end
        
        % Function called with user clicks on the image (superpix. selection)
        function selectionCallback(obj, hObject, ~)
            
            allAxesInFigure = findall(hObject,'type','axes');
            hAxes = allAxesInFigure(1);
            
            % Conversion from axis position to pixels indexes
            pos = get(hAxes, 'CurrentPoint');
            posX = pos(1,1,1);
            posY = pos(1,2,1);
            
            indI = min(max(round(posX), 1), size(obj.segmentations, 2));
            indJ = min(max(round(posY), 1), size(obj.segmentations, 1));
            obj.selectedIdx = obj.segmentations(indJ, indI, obj.currentSegmInd);
            
            % If wanted, apply label modification to the whole region
            if obj.applyLabelChange
                idx = (obj.segmentations(:,:, obj.currentSegmInd) == obj.selectedIdx);
                thisLabels = obj.labels(:,:,obj.currentSegmInd);
                thisLabels(idx) = obj.selectedLabel;
                obj.labels(:,:,obj.currentSegmInd) = thisLabels;
            end
            
            obj.displayImage;
            
        end
        
        function guessLabels(obj)
            
            thisSegm = obj.segmentations(:,:,obj.currentSegmInd);
            thisLabels = obj.labels(:,:,obj.currentSegmInd);
            
            % Check that at least two different labels have been defined
            if length(unique(nonzeros(thisLabels))) < 2
                disp('At least two different labels should be defined');
                return
            end
            
            pixels = obj.originalImageLAB;
            pixels = reshape(pixels, [size(pixels, 1)*size(pixels, 2), size(pixels, 3)]);
            
            labelClearPixs = pixels(thisLabels == 1, :);
            labelPuffyPixs = pixels(thisLabels == 2, :);
            labelThickPixs = pixels(thisLabels == 3, :);
            labelThinPixs = pixels(thisLabels == 4, :);
            labelVeilPixs = pixels(thisLabels == 5, :);
            
            % Create the GMM models for the existing data
            labelClearGMM = obj.estimateGMM(labelClearPixs);
            labelPuffyGMM = obj.estimateGMM(labelPuffyPixs);
            labelThickGMM = obj.estimateGMM(labelThickPixs);
            labelThinGMM = obj.estimateGMM(labelThinPixs);
            labelVeilGMM = obj.estimateGMM(labelVeilPixs);
            
            % Computing the priors by considering the areas
            nnzelems = nnz(thisLabels > 0 & thisLabels ~= 42 & thisLabels ~= 43);
            PlabelClear = nnz(thisLabels == 1)/nnzelems;
            PlabelPuffy = nnz(thisLabels == 2)/nnzelems;
            PlabelThick = nnz(thisLabels == 3)/nnzelems;
            PlabelThin = nnz(thisLabels == 4)/nnzelems;
            PlabelVeil = nnz(thisLabels == 5)/nnzelems;
            
            % Compute the optimal label for each superpixel
            for i = unique(obj.segmentations(:,:,obj.currentSegmInd))'
                
                thisRegion = thisSegm == i;
                
                if thisLabels(find(thisRegion, 1, 'first')) == 0
                    
                    thisPixels = double(pixels(thisRegion == 1, :));
                    probXgivenClear = mean(labelClearGMM.pdf(thisPixels));
                    probXgivenPuffy = mean(labelPuffyGMM.pdf(thisPixels));
                    probXgivenThick = mean(labelThickGMM.pdf(thisPixels));
                    probXgivenThin = mean(labelThinGMM.pdf(thisPixels));
                    probXgivenVeil = mean(labelVeilGMM.pdf(thisPixels));
                    
                    probX = probXgivenClear * PlabelClear + probXgivenPuffy * PlabelPuffy +...
                        probXgivenThick * PlabelThick +...
                        probXgivenThin * PlabelThin + probXgivenVeil * PlabelVeil;
                    
                    probClear = probXgivenClear * PlabelClear / probX;
                    probPuffy = probXgivenPuffy * PlabelPuffy / probX;
                    probThick = probXgivenThick * PlabelThick / probX;
                    probThin = probXgivenThin * PlabelThin / probX;
                    probVeil = probXgivenVeil * PlabelVeil / probX;
                    
                    % Max probability : new label
                    [~, newLabel] = max([probClear probPuffy probThick ...
                        probThin probVeil]);
                    
                    thisLabels(thisRegion) = newLabel;
                    
                end
                
            end
            
            obj.currentSegmInd = obj.currentSegmInd + 1;
            obj.segmentations(:,:,obj.currentSegmInd) = thisSegm;
            obj.labels(:,:,obj.currentSegmInd) = thisLabels;
            
            if(size(obj.segmentations, 3) > obj.currentSegmInd)
                obj.segmentations(:,:,obj.currentSegmInd + 1:end) = [];
                obj.labels(:,:,obj.currentSegmInd + 1:end) = [];
            end
            
            obj.displayImage;
            
        end
        
        function save(obj)
            
            segm = obj.labels(:,:,obj.currentSegmInd);
            save(['images/', obj.imageName,'_CGT.mat'], 'segm');
            
        end
        
    end
    
    methods (Static)
        
        function gmm = estimateGMM(pixels)
            
            % We disable the warnings : it is normal that some GMM fitting
            % does not converge
            warning('off','all');
            
            pixels = double(pixels);
            
            if size(pixels, 1) ~= 0
                
                % We estimate the number of componenents using the BIC
                % criterion over a subset of the pixels
                subset = pixels(1:10:end, :);
                BICs = zeros(1,5);
                for nbComps = 1:5
                    GMM = gmdistribution.fit(subset, nbComps, 'Regularize', 10^-6);
                    BICs(nbComps) = GMM.BIC;
                end
                [~, optimalNbComps] = max(BICs);

                gmm = gmdistribution.fit(pixels, optimalNbComps);
            
            else
                
                % We create a fake GMM for which a pixel will never have
                % the biggest probability to come from
                gmm = gmdistribution([10000 10000 10000], eye(3,3));
                
            end
            
            warning('on','all');
                
        end
        
        function segmOut = splitDisconnectedSuperpixels(segmIn)
            
            idToAssign = uint16(max(segmIn(:)) + 1);
            
            % We iterate through every region
            allLabels = unique(segmIn(:));
            
            segmOut = uint16(segmIn);
            
            for i=1:length(allLabels)
                
                thisLabel = segmIn == allLabels(i);
                
                CC = bwconncomp(thisLabel, 8);
                
                if CC.NumObjects > 1
                    
                    for area = 2:CC.NumObjects
                        
                        segmOut(CC.PixelIdxList{area}) = idToAssign;
                        idToAssign = idToAssign + 1;
                        
                    end
                    
                end
                
            end
            
        end
        
        % Merge all superpixels with area less than 30% of regionSize with
        % the one with which it shares the longest boundary (but same label)
        function segmOut = mergeSmallSuperpixels(segmIn, labels, regionSize)
            
            allLabels = unique(segmIn(:));
            
            segmOut = segmIn;
            
            for i=1:length(allLabels)
                
                thisSuperpix = segmIn == allLabels(i);
                
                if bwarea(thisSuperpix) < 0.2*regionSize
                    
                    % Find boundary of this superpixel
                    % boundaryIdx = cell2mat(bwboundaries(imdilate(thisSuperpix, strel('diamond', 1))));
                    % boundaryIdx = sub2ind(size(thisSuperpix), boundaryIdx(:,1), boundaryIdx(:,2));
                    % boundary = zeros(size(thisSuperpix));
                    % boundary(boundaryIdx) = 1;
                    boundary = bwperim(imdilate(thisSuperpix, strel('diamond', 1)));
                    
                    labelThisSuperpix = labels(find(thisSuperpix ~= 0, 1, 'first'));
                    if(labelThisSuperpix ~= 0) % We should look for a superpixel with same label
                        boundary = boundary .* (labels == labelThisSuperpix);
                    end
                    
                    % We don't take elements for the background
                    boundary = boundary .* (labels ~= 43);
                    
                    boundary = uint16(boundary) .* segmOut;
                    
                    allBoundSegmLabels = boundary(boundary ~= 0);
                    newSegmLabel = mode(double(allBoundSegmLabels));
                    if isnan(newSegmLabel)
                        newSegmLabel = labelThisSuperpix;
                    end
                    
                    segmOut(thisSuperpix) = newSegmLabel;
                    
                end
                
            end
            
        end
        
    end
    
end

