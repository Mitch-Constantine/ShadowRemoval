classdef VideoFilter    
    properties
        InputFile
        OutputFile
        VideoFilters
        ImagesX
        ImagesY
    end
    
    methods
        function generateImages(VideoFilter)
            imageReader = VideoReader(VideoFilter.InputFile);
            imageWriter = VideoWriter(VideoFilter.OutputFile);
            
            for frameCrt = 1 : imageReader.NumberOfFrames
                originalFrame = imageReader.read(frameCrt);
                compositeFrame = GenerateCompositeFrame(originalFrame);
                imageWriter.Write(compositeFrame);
            end
            imageWriter.close();
        end
        
        function GenerateCompositeFrame(VideoFilter, compositeFrame)
            for compositeX = 
        end
    end
    
end

