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
                success: function(data) {
                    if (data["pics"]) {
                        console.log(data["pics"])
                        d = new Date();
                        $("#locPNG").prop("src", data["pics"]["locPNG"] + "?" + d.getTime())
                        $("#piePNG").prop("src", data["pics"]["piePNG"] + "?" + d.getTime())
                        $("#wordCloudPNG").prop("src", data["pics"]["wordCloudPNG"] + "?" + d.getTime())
                        $("#divImage").show();
                    } else {
                        $("#divImage").hide();
                        // window.location.replace(data["redirect"]);
                    }
                }
            });
            return $(e.target).blur().focus();
        }
    });
});