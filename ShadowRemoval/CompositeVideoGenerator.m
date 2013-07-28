classdef CompositeVideoGenerator    
    properties
        InputFile
        OutputFile
        Filters
    end
    
    methods
        function this = CompositeVideoGenerator(inputFile, outputFile, filters)
            this.InputFile = inputFile;
            this.OutputFile = outputFile;
            this.Filters = filters;
        end
        
        function Generate(this, maxFrames)
            fprintf('%s\n', datestr(now));
            imageReader = VideoReader(this.InputFile);
            fprintf('Reading input file\n');
            allFrames = imageReader.read();
            fprintf('Input file read\n');
            imageWriter = VideoWriter(this.OutputFile);
            imageWriter.open();
            
            frames = size(allFrames, 4);
            if nargin == 2
                frames = min(frames, maxFrames);
            end
            
            for frameCrt = 1 : frames
                originalFrame = squeeze(allFrames(:, :, :, frameCrt));
                compositeFrame = this.GenerateCompositeFrame(originalFrame);
                imageWriter.writeVideo(compositeFrame);
                fprintf('%s\n', datestr(now));
                fprintf('Frame %d\n', frameCrt);
                drawnow('update');
                java.lang.System.gc();
            end
            fprintf('\n');
            imageWriter.close();
        end
        
        function compositeFrame = GenerateCompositeFrame(this, originalFrame)
            
            filteredImages = this.RunFilters(originalFrame);
            compositeFrame = this.BuildCompositeFrame(originalFrame, filteredImages);
            
        end
        
        function filteredImages = RunFilters(this, originalFrame)
            
            numberOfFilters = length(this.Filters);
            for ndxFilterCrt = 1 : numberOfFilters
                filterCrt = this.Filters{ndxFilterCrt};
                filterCrt.Feed(originalFrame);
            end
            
            filteredImages = cell(1, numberOfFilters);
            for ndxFilterCrt = 1 : numberOfFilters
                filterCrt = this.Filters{ndxFilterCrt};
                newImage = filterCrt.GetFilteredImage(originalFrame);
                filteredImages{ndxFilterCrt} = newImage;
            end            
           
        end
        
        function compositeFrame = BuildCompositeFrame(this, originalFrame, images)

            compositeFrame = this.SizeCompositeFrame(originalFrame);
            compositeFrame = this.SetFramePart(compositeFrame, originalFrame, 1);
            for ndxImageCrt = 1 : length(images)
                compositeFrame = this.SetFramePart(compositeFrame, images{ndxImageCrt}, ndxImageCrt+1);
            end
        
        end
        
        function emptyImage = SizeCompositeFrame(this, original)
            xSize = size(original, 2)*this.GetImagesX();
            ySize = size(original, 1)*this.GetImagesY();
            emptyImage = zeros(ySize, xSize, 3, 'uint8');
        end
        
        function modifiedFrame=SetFramePart(this, compositeFrame, image, position)
            positionX = mod(position-1, this.GetImagesX());
            startX = size(image, 2)*positionX+1;
            endX = size(image,2)*(positionX+1);
            
            positionY = floor( (position-1) / this.GetImagesX());
            startY = size(image, 1)*positionY+1;
            endY = size(image,1)*(positionY+1);
            
            modifiedFrame = compositeFrame;
            modifiedFrame(startY : endY, startX : endX, :) = image;
        end
        
        function imagesX = GetImagesX(this)
            imagesX = ceil(sqrt(length(this.Filters)+1));
        end
        
        function imagesY = GetImagesY(this)
            imagesY = floor(sqrt(length(this.Filters)+1));
        end
        
    end
    
    methods(Static)
        function test()
            filters = { ForceColourFilter(1), ForceColourFilter(2), ForceColourFilter(3) };
            generator = CompositeVideoGenerator('~/Dropbox/SportRFID/Data Samples for Skiing/Sample_30.mp4', '~/Test01.mp4', filters);
            generator.Generate();
        end
    end
    
end

