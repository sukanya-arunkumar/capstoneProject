EXPLORE DATA
------------

### Working with Yellow and Green datasets

I wanted to visualize the density of the `trip_distance`, I used
`quantile` to set the `trip_distance` threshold with a 90% probability.

    taxiData <-
      read.csv('../clean_yellow_green_data.csv', stringsAsFactors = FALSE)

    threshold <- quantile(taxiData$trip_distance, probs=0.9)

    ggplot(taxiData, aes(x=trip_distance, fill=taxi_color, alpha=I(0.4))) + 
      xlim(min(taxiData$trip_distance),max(taxiData$trip_distance)) +
      geom_density() + 
      geom_vline(xintercept=threshold) +
      scale_fill_manual(values=c("#006600", "#e5e500")) +
      labs(fill = 'Taxi Color', x = 'Trip Distance (in miles)', y = 'Density')

![](README_files/figure-markdown_strict/unnamed-chunk-1-1.png)

The trip distance threshold is 3.8 miles I decided to create a discrete
modal with the new trip distance threshold

    distance_type_label <- c('TRUE' = paste('Trip Distance > ', threshold), 'FALSE' = paste('Trip Distance <= ', threshold))
    ggplot(transform(taxiData,
                     long_distance = trip_distance > threshold), aes(x=trip_distance, fill=taxi_color, alpha=I(0.4))) + 
      geom_density() + 
      scale_fill_manual(values=c("#006600", "#e5e500")) +
      facet_grid (~long_distance,scales = "free", labeller=as_labeller(distance_type_label)) +
      labs(fill = 'Taxi Color', x = 'Trip Distance (in miles)', y = 'Density')

![](README_files/figure-markdown_strict/unnamed-chunk-2-1.png)