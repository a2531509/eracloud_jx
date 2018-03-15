<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
    function setImagePreview(obj, localImagId, imgObjPreview) {  
        var array = new Array(/*'gif',*/ 'jpeg', /*'png',*/ 'jpg'/*, 'bmp'*/); //可以上传的文件类型  
        if(obj.value == '') {  
            $.messager.alert("系统消息","请选择要上传的图片！","warning");  
            return false;  
        }else{  
            var fileContentType = obj.value.match(/^(.*)(\.)(.{1,8})$/)[3];
            var isExists = false;  
            for (var i in array){  
                if (fileContentType.toLowerCase() == array[i].toLowerCase()) {  
                    if (obj.files && obj.files[0]) {  
                        imgObjPreview.style.display = 'inline';  
                        imgObjPreview.style.width = '100px';  
                        imgObjPreview.style.height = '100px';  
                        imgObjPreview.src = window.URL.createObjectURL(obj.files[0]);  
                    }else{  
                        obj.select();  
                        var imgSrc = document.selection.createRange().text;  
                        localImagId.style.width = "100px";  
                        localImagId.style.height = "100px";  
                        try {  
                            localImagId.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale)";  
                            localImagId.filters.item("DXImageTransform.Microsoft.AlphaImageLoader").src = imgSrc;  
                        }  
                        catch (e) {  
                            $.messager.alert("系统消息","您上传的图片格式不正确，请重新选择！","error");
                            return false;  
                        }  
                        imgObjPreview.style.display = 'none';  
                        document.selection.empty();  
                    }  
                    isExists = true;  
                    return true;  
                }  
            }
            if (isExists == false) {  
                $.messager.alert("系统消息","上传图片类型不正确！","error");
                return false;  
            }  
            return false;  
        }  
    }  
    function over(imgid, obj, imgbig) {  
        maxwidth = 100;  
        maxheight = 40;  
        obj.style.display = "";  
        imgbig.src = imgid.src;  
        if (imgid.width > maxwidth && imgid.height > maxheight) {  
            pare = (imgid.width - maxwidth) - (imgid.height - maxheight);  
            if (pare >= 0){ 
                imgid.width = maxwidth; 
            }else{
                imgid.height = maxheight; 
            }  
        }else if (imgid.width > maxwidth && imgid.height <= maxheight) {  
            imgid.width = maxwidth;  
        }else if (imgid.width <= maxwidth && imgid.height > maxheight) {  
            imgid.height = maxheight;  
        } 
    }  
    function fileUpload(callback) {
    	if($("#idFile").val() == "" && $("#imgPhotoConts").val() == ""){
    		jAlert("请选择上传照片或读取身份证照片！");
    		return;
    	}
    	if(document.getElementById("idFile").value != ""){
	    	if(!setImagePreview(document.getElementById("idFile"),localImag,document.getElementById("preview"))){
	    		return;
	    	}
    	}
        var files = ["idFile"];
        var selectId = $("#personPhotoId").val();
        $.messager.confirm("系统消息", "您确定要上传选定的照片？", function(r){
        	if(r){
        		$.messager.progress({text:"数据处理中，请稍后...."});
        		if($("#idFile").val() != ""){
	     			$.ajaxFileUpload({
	            		url:"basicPhotoAction/basicPhotoAction!fileUpload.action?personPhotoId=" + selectId + "&personPhotoContent=" + $("#imgPhotoConts").val(),     //用于文件上传的服务器端请求地址  
	            		secureuri:false,
	            		fileElementId:files,
	            		dataType:"json", 
	            		success:function(data,status) {
			          		$.messager.progress("close");
			          		if(data.status == "0") {
				            	$.messager.alert("系统消息",data.errMsg,"info",function(){
				            		$.modalDialog.handler.dialog("close");
				            	});
				            	if(typeof($grid) != "undefined"){
				          	  		$grid.datagrid("reload");
				            	}
				            	if(typeof(callback) == "function"){
				            		callback();
				            	}
			          		}else{
			          			$.messager.alert("系统消息",data.errMsg,"error");
			          		}
			            },error:function(data,status, e) {
	                 	    $.messager.progress("close");
	                        $.messager.alert("系统消息",data.errMsg,"error");
	                    }
	                });
        		}else{
        			$.post("basicPhotoAction/basicPhotoAction!fileUpload.action?personPhotoId=" + selectId,{personPhotoContent:$("#imgPhotoConts").val()},function(data,status){
        				if(status == "success"){
        					$.messager.progress("close");
			          		if(data.status == "0") {
				            	$.messager.alert("系统消息",data.errMsg,"info",function(){
				            		$.modalDialog.handler.dialog("close");
				            	});
				            	if(typeof($grid) != "undefined"){
				          	  		$grid.datagrid("reload");
				            	}
				            	if(typeof(callback) == "function"){
				            		callback();
				            	}
			          		}else{
			          			$.messager.alert("系统消息",data.errMsg,"error");
			          		}
        				}else{
        					$.messager.progress("close");
	                        $.messager.alert("系统消息",data.errMsg,"error");
        				}
        			},"json");
        		}
     	    }
        });
    } 
    function readIDCard2() {
    	$.messager.progress({text:"正在获取证件信息，请稍后...."});
    	var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
    	imgDeal.getImgMessageByCard(o["photo"],function(data){
    		if(data.isOK == "0"){
   	  			dwr.util.setValue("preview",data.imageMsg);
		    	$("#imgPhotoConts").val(o["photo"]);
			}else{
				jAlert(data.errMsg);
			}
	  	});
    }
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" action="" enctype="multipart/form-data">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>照片选择</legend>
				<input type="hidden" id="imgPhotoConts" name="imgPhotoConts">
				<input name="personPhotoId" id="personPhotoId"  type="hidden" value="<%=request.getParameter("personPhotoId") %>"/>
				 <div data-options="region:'center',border:true" title="" style="height:auto;overflow: hidden;padding: 10px;text-align:center;">
                    <table>
                        <tr>
                            <th>选择图片：</th>
                            <td>
                            	<input id="idFile" style="width:550px"  name="file" onchange="javascript:setImagePreview(this,localImag,document.getElementById('preview'));" type="file" />
                            	<a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-readIdcard" plain="false" onclick="readIDCard2();">读取身份证</a>
                            </td>
                        </tr>
                        <tr>
                             <td colspan="3" style="text-align:left;">
                                <span style="color:red">*请正确选择您要导入的照片，照片类型为jpg格式，照片大小不能超过500K。如果该客户已经存在照片，导入的照片将会覆盖该客户原先的照片*</span>
                             </td>
                        </tr>
                    </table>
                    <hr style="color:rgb(149,184,231);border-style:dashed;width:480;"/> 
                        <div>
                            <h4 style="position: absolute; left: 0.1in;">预　　 览：</h4>
                        </div>
                    <div id="localImag" style="width:121px;height:148px;margin-left:60px;">  
                        <img id="preview" style="width:120px;height:147px;" onclick="over(preview,divImage,imgbig);" />   
                    </div>
            	</div>  
			</fieldset>
		</form>
	</div>
</div>