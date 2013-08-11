classdef ShadowRemovalCppFilter < handle

    properties
        BackgroundModel
        ChainedBackgroundSubtractionFilter
        
        Algorithm
    end
    
    methods

        function this = ShadowRemovalCppFilter(backgroundSubtractionFilter, algorithm)
            this.ChainedBackgroundSubtractionFilter = backgroundSubtractionFilter;
            this.Algorithm = algorithm;
        end
                       
        function Feed(this, image)        
        end
        
        function filteredImage = GetFilteredImage(this, image)
            backgroundFiltered = this.ChainedBackgroundSubtractionFilter.GetFilteredImage(image);
            movementMask = (squeeze(backgroundFiltered(:,:,1)) > 0);
            this.BackgroundModel = this.AdjustBackgroundModel(image, movementMask);            
            withoutShadows = this.SuppressShadows(movementMask, image);
            filteredImage = ShadowRemovalCppFilter.MaskToRGB(withoutShadows);
        end
        
        function newBackgroundModel = AdjustBackgroundModel(this,image, movementMask)
            if isempty(this.BackgroundModel) 
                newBackgroundModel = image;
            else
                newBackgroundModel = zeros(size(image), 'uint8');
                mask = uint8(movementMask);
                newBackgroundModel( :, :, 1) = squeeze(this.BackgroundModel(:, :, 1)) .* mask + squeeze(image(:, :, 1)) .* (1-mask);
                newBackgroundModel( :, :, 2) = squeeze(this.BackgroundModel(:, :, 2)) .* mask + squeeze(image(:, :, 2)) .* (1-mask);
                newBackgroundModel( :, :, 3) = squeeze(this.BackgroundModel(:, :, 3)) .* mask + squeeze(image(:, :, 3)) .* (1-mask);
                this.BackgroundModel = newBackgroundModel;
            end
        end
        
        function withoutShadows = SuppressShadows(this, movementMask, image)
            withoutShadows = matlabRemoveShadows(this.Algorithm, image, movementMask, this.BackgroundModel);
        end
        
    end
    
    methods(Static)
        function rgb = MaskToRGB(binary)
            rgb = zeros(size(binary,1), size(binary,2), 3, 'uint8');
            rgb(:, :, 1) = binary * 255;
            rgb(:, :, 2) = binary * 255;
            rgb(:, :, 3) = binary * 255;
        end
        
    end

    methods(Static)
        function testOne()
            filters = ShadowRemovalCppFilter.getFilters();
            
            generator = CompositeVideoGenerator('~/Samples/Sample_44.mp4', '~/Test02.mp4', filters);
            generator.Generate(148);
        end
        
        function testAll()
            filters = ShadowRemovalCppFilter.getFilters();
            
            [inputFiles, outputFiles] = ShadowRemovalCppFilter.getFilesToProcess('~/Samples');
            for i = 1 : length(inputFiles)
                inputFile = inputFiles{i};
                outputFile = outputFiles{i};
                generator = CompositeVideoGenerator(inputFile, outputFile, filters);
                generator.Generate(0);
            end
        end
        
        function [inputFiles, outputFiles] = getFilesToProcess(path)
            fileSpec = strcat( path, '/*.mp4');
            listing = dir(fileSpec);
            fileCount = length(listing);
            
            inputFiles = cell(fileCount, 1);
            outputFiles = cell(fileCount, 1);
            
            pathSlash = strcat(path, '/');
            for i = 1 : fileCount
                inputFileName = listing(i).name;
                inputFiles{i} = strcat(pathSlash, inputFileName);
                
                outputFileName = strrep(inputFileName, '.mp4', '_test');
                outputFiles{i} = strcat(pathSlash, outputFileName);
            end
        end
        
        function filters = getFilters()
            backgroundSubtractionFilter = BackgroundSubtractionFilter();
            filter1 = ShadowRemovalCppFilter(backgroundSubtractionFilter, 1);
            filter2 = ShadowRemovalCppFilter(backgroundSubtractionFilter, 2);
            filter3 = ShadowRemovalCppFilter(backgroundSubtractionFilter, 3);
            filter4 = ShadowRemovalCppFilter(backgroundSubtractionFilter, 4);
            filter5 = ShadowRemovalCppFilter(backgroundSubtractionFilter, 5);
            filters = { backgroundSubtractionFilter, filter1, filter2, filter3, filter4, filter5 };
        end
        
    end
    
end

