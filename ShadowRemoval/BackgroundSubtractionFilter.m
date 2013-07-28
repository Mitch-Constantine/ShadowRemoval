classdef BackgroundSubtractionFilter < handle

    properties
        BackgroundSubtractionParameters
        FilteredImage
    end
    
    methods
        function Feed(this, image)        
            [backSubRawMap, this.BackgroundSubtractionParameters] = backSub(image,this.BackgroundSubtractionParameters);
            binaryImage = im2bw(backSubRawMap, 0.5);
            this.FilteredImage = zeros( size(image), 'uint8');
            this.FilteredImage(:, :, 1) = binaryImage * 255;
            this.FilteredImage(:, :, 2) = binaryImage * 255;
            this.FilteredImage(:, :, 3) = binaryImage * 255;
        end
        
        function filteredImage = GetFilteredImage(this, image)
            filteredImage = this.FilteredImage;
        end
        
    end

    methods(Static)
        function test()
            filters = { BackgroundSubtractionFilter() };
            generator = CompositeVideoGenerator('~/Samples/Sample_44.mp4', '~/Test02.mp4', filters);
            generator.Generate();
        end
    end
    
end

