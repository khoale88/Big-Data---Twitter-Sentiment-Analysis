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
                success: function(data, textStatus, xhr) {

                },
                complete: function(xhr, textStatus) {
                    console.log(xhr.status);
                    if (xhr.status === 204) {
                        console.log("Inside");
                        $("#divContent").show();
                        getWordCloud();
                        // getTrendingTweets();
                    }
                }
            });
            return $(e.target).blur().focus();
        }
    });
});

function getWordCloud() {
    console.log("getWordCloud");
    $.ajax({
        type: 'GET',
        url: "/wordCloud",
        dataType: "json",
        success: function(data, textStatus, xhr) {
            console.log(xhr.status);
            $("#imgWordCloud").prop("src", data["wordCloud"] + "?" + d.getTime());
            getPieChart();
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getWordCloud, 2000);
            }
        }
    });
}

function getPieChart() {
    console.log("getPieChart");
    $.ajax({
        type: 'GET',
        url: "/pieChart",
        dataType: "json",
        success: function(data, textStatus, xhr) {
            console.log(xhr.status);
            $("#imgWordCloud").prop("src", data["pieChart"] + "?" + d.getTime());
            // getLocationMap();
        },
        complete: function(xhr, textStatus) {
            if (xhr.status === 202) {
                setTimeout(getPieChart, 2000);
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
            console.log(xhr.status);
            if (xhr.status === 202) {
                setTimeout(getLocationMap, 2000);
            } else if (xhr.status === 200) {
                $("#imgLocationMap").prop("src", data["locMap"] + "?" + d.getTime());
            }
        },
        complete: function(xhr, textStatus) {

        }
    });
}

function getTrendingTweets() {
    $.ajax({
        type: 'GET',
        url: "/topTrends",
        dataType: "json",
        success: function(data, textStatus, xhr) {
            console.log(xhr.status);
            if (xhr.status === 202) {
                setTimeout(getWordCloud, 2000);
            } else if (xhr.status === 200) {

            }
        },
        complete: function(xhr, textStatus) {

        }
    });
}