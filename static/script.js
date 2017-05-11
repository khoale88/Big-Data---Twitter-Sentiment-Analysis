$(document).ready(function() {

    $(document).on('keypress', '#searchTerm', function(e) {

        if (e.keyCode == 13 && e.target.type !== 'submit') {
            e.preventDefault();
            if ($("#searchTerm").val() === "" || $("#searchTerm").val().length < 3) return;

            $.ajax({
                type: 'POST',
                url: $("#searchTerm").data("url"),
                contentType: 'application/json;charset=UTF-8',
                data: JSON.stringify({
                    "searchTerm": $("#searchTerm").val()
                }, null, '\t'),
                dataType: "json",
                beforeSend: function(xhr) {
                    $("#divContent").hide();
                    $(".divWordCloud").hide();
                    $(".divPieChart").hide();
                    $(".divLocationMap").hide();
                },
                success: function(data, textStatus, xhr) {

                },
                complete: function(xhr, textStatus) {
                    if (xhr.status === 204) {
                        $("#divContent").show(1000);
                        setTimeout(getWordCloud, 3000);
                        setTimeout(getTrendingTweets, 3000);
                        setTimeout(getAllTweets, 3000);
                    }
                }
            });
            return $(e.target).blur().focus();
        }
    });

    $("img").on('error', function() {
        console.log("error loading image");
        d = new Date();
        var image = $(this);
        setTimeout(function() {
            image.prop("src", image.prop("src") + d.getTime()).show(1500);
        }, 500);
    });
});

function getWordCloud() {
    $.ajax({
        type: 'GET',
        url: "/wordCloud",
        dataType: "json",
        success: function(data, textStatus, xhr) {
            d = new Date();
            $("#imgWordCloud").prop("src", data["wordCloud"] + "?" + d.getTime());
            $(".divWordCloud").show(1500);
            getPieChart();
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getWordCloud, 3000);
            }
        }
    });
}

function getPieChart() {
    $.ajax({
        type: 'GET',
        url: "/pieChart",
        dataType: "json",
        success: function(data, textStatus, xhr) {
            d = new Date();
            $("#imgPieChart").prop("src", data["pieChart"] + "?" + d.getTime());
            $(".divPieChart").show(1500);
            getLocationMap();
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getPieChart, 3000);
            }
        }
    });
}

function getLocationMap() {
    $.ajax({
        type: 'GET',
        url: "/locMap",
        dataType: "json",
        success: function(data, textStatus, xhr) {
            d = new Date();
            $("#imgLocationMap").prop("src", data["locMap"] + "?" + d.getTime());
            $(".divLocationMap").show(1500);
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getLocationMap, 3000);
            }
        }
    });
}

function getTrendingTweets() {
    if ($(".trendingtweets").is(':empty')) return;
    $.ajax({
        type: 'GET',
        url: "/topTrends",
        dataType: "html",
        success: function(data, textStatus, xhr) {
            $(".trendingtweets").html(data);
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getTrendingTweets, 3000);
            }
        }
    });
}

function getAllTweets() {
    $.ajax({
        type: 'GET',
        url: "/tweets",
        dataType: "html",
        success: function(data, textStatus, xhr) {
            $(".allTweets").html(data);
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getAllTweets, 3000);
            }
        }
    });
}