classdef ShadowRemovalFilter < handle

    properties(Constant)
        THRESHOLD_H = 0.001
        THRESHOLD_S = 0.01
        LOWER_THRESHOLD_V = 0.1
        UPPER_THRESHOLD_V = 0.7
        
        USE_H = 1;
        USE_S = 2;
        USE_V = 4;
    end
    
    properties
        BackgroundModel
        ChainedBackgroundSubtractionFilter
        
        UseLayers;
    end
    
    methods

        function this = ShadowRemovalFilter(backgroundSubtractionFilter, mode)
            this.ChainedBackgroundSubtractionFilter = backgroundSubtractionFilter;
            this.UseLayers = mode;
        end
                       
        function Feed(this, image)        
        end
        
        function filteredImage = GetFilteredImage(this, image)
            backgroundFiltered = this.ChainedBackgroundSubtractionFilter.GetFilteredImage(image);
            movementMask = (squeeze(backgroundFiltered(:,:,1)) > 0);
            this.BackgroundModel = this.AdjustBackgroundModel(image, movementMask);            
            withoutShadows = this.SuppressShadows(movementMask, image);
            filteredImage = ShadowRemovalFilter.MaskToRGB(withoutShadows);
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
            hsvImage = rgb2hsv(image);
            hsvBackground = rgb2hsv(this.BackgroundModel);
                        
            withoutShadows = movementMask;
            
            if this.Use(ShadowRemovalFilter.USE_H)
                hMask = 1-ShadowRemovalFilter.IsCompatibleH(ShadowRemovalFilter.H(hsvImage), ShadowRemovalFilter.H(hsvBackground));
                withoutShadows = withoutShadows & hMask;
            end
            if this.Use(ShadowRemovalFilter.USE_S)
                sMask = 1-ShadowRemovalFilter.IsCompatibleS(ShadowRemovalFilter.S(hsvImage), ShadowRemovalFilter.S(hsvBackground));
                withoutShadows = withoutShadows & sMask;
            end
            if this.Use(ShadowRemovalFilter.USE_V)
                vMask = 1-ShadowRemovalFilter.IsCompatibleV(ShadowRemovalFilter.V(hsvImage), ShadowRemovalFilter.V(hsvBackground));
                withoutShadows = withoutShadows & vMask;                
            end
        end
        
        function use = Use(this, flag)
            use = ((this.UseLayers & flag) > 0);
        end
        
    end
    
    methods(Static)
        function rgb = MaskToRGB(binary)
            rgb = zeros(size(binary,1), size(binary,2), 3, 'uint8');
            rgb(:, :, 1) = binary * 255;
            rgb(:, :, 2) = binary * 255;
            rgb(:, :, 3) = binary * 255;
        end
        
        function h = H(hsv)
            h = hsv(:, :, 1);
        end
        
        function s = S(hsv)
            s = hsv(:, :, 2);
        end
        
        function v = V(hsv)
            v = hsv(:, :, 3);
        end
        
        function mask = IsCompatibleH(image, background)
            mask = abs(image-background) <= ShadowRemovalFilter.THRESHOLD_H;
        end
        
        function mask = IsCompatibleS(image, background)
            mask = image-background <= ShadowRemovalFilter.THRESHOLD_S;
        end
        
        function mask = IsCompatibleV(image, background)
            mask = ( (ShadowRemovalFilter.LOWER_THRESHOLD_V)*background <= image ) & ...
                ( (ShadowRemovalFilter.UPPER_THRESHOLD_V)*background >= image );
        end
    end

    methods(Static)
        function test()
            backgroundSubtractionFilter = BackgroundSubtractionFilter();
            hFilter = ShadowRemovalFilter(backgroundSubtractionFilter, ShadowRemovalFilter.USE_H);
            sFilter = ShadowRemovalFilter(backgroundSubtractionFilter, ShadowRemovalFilter.USE_S);
            vFilter = ShadowRemovalFilter(backgroundSubtractionFilter, ShadowRemovalFilter.USE_V);
            shadowFilter = ShadowRemovalFilter(backgroundSubtractionFilter, ...
                ShadowRemovalFilter.USE_H + ShadowRemovalFilter.USE_S + ShadowRemovalFilter.USE_V);
            filters = { backgroundSubtractionFilter, hFilter, sFilter, vFilter, shadowFilter };
            generator = CompositeVideoGenerator('~/Samples/Sample_44.mp4', '~/Test02.mp4', filters);
            generator.Generate(148);
        end
    end
    
end

