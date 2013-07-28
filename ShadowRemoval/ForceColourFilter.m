classdef ForceColourFilter
    
    properties
        LayerNo 
    end
    
    methods
        function this = ForceColourFilter(layerNo)
            this.LayerNo = layerNo;
        end
        
        function Feed(this, image)        
        end
        
        function filteredImage = GetFilteredImage(this, image)
            filteredImage = image;
            filteredImage( :, :, this.LayerNo) = 255;
        end
    end
    
end

