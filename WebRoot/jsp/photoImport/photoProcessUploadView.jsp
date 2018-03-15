<%@ page language="java" import="java.util.*" pageEncoding="utf-8" %>
<%--
	功能模块：照片处理上传视图。
	功能描述：通过文件选择对话框选择一张要上传的图片，在处理区域内对照片进行移动、缩放、旋转、裁剪等操作，
			同时在预览区域内可实时显示已选择裁剪区域的图像，单击上传按钮可完成对图片的上传。
	作者：钱佳明。
	日期：2016年3月29日。
	邮箱：qianjiaminghz@qq.com。
	版本：1.0。
 --%>
<script type="text/javascript">
	// 照片文件对象
	var photoFileObject = document.getElementById("photoFile");
	// 照片文件处理对象
	var photoFileDataObject = document.getElementById("photoFileData");
	// 照片处理开关
	var photoProcessSwitch = false;
	// 照片缩放值
	var photoZoom = 0;
	// 照片处理数据
	var photoProcessData = "";
	// 允许上传照片文件类型
	var photoFileExtRegex = /\.(jpg|jpeg)$/;
	// 允许上传照片宽度
	var photoWith = 358;
	// 允许上传照片高度
	var photoHeight = 441;
	// 是否身份证照片
	var isIdPhoto = false;

	// 检查照片文件
	function checkPhotoFile() {
		// 获取照片文件路径
		var photoFilePath = photoFileObject.value;
		// 判断是否选择照片文件
		if (photoFilePath == null || photoFilePath == "") {
			$.messager.alert("系统消息", "请选择您要上传的照片文件！", "info");
			return false;
		}
		// 判断照片文件类型
		if (!/\.(jpg|jpeg|JPG|JPEG)$/.test(photoFilePath)) {
			$.messager.alert("系统消息", "您选择的照片文件类型不正确！请重新选择！", "error");
			photoFileObject.value = "";
			return false;
		}
		return true;
	}

	// 渲染照片文件数据
	function renderPhotoFileData() {
		if (checkPhotoFile()) {
			// 获取浏览器标识
			var userAgent = window.navigator.userAgent;
			if (photoFileObject.files && photoFileObject.files[0]) {
				// 非IE浏览器环境
				if (userAgent.indexOf("Chrome") != -1 || userAgent.indexOf("Safari") != -1) {
					// Chrome或Safari浏览器
					photoFileDataObject.src = window.webkitURL.createObjectURL(photoFileObject.files[0]);
				} else {
					// Firefox或Netscape浏览器
					photoFileDataObject.src = window.URL.createObjectURL(photoFileObject.files[0]);
				}
			} else {
				// IE10以下浏览器环境
				$.messager.alert("系统消息", "当前浏览器不支持照片文件数据处理！请使用IE11或更高版本的浏览器！", "error");
				photoFileObject.value = "";
				return false;
			}
			return true;
		}
		return false;
	}

	// 开启照片处理
	function openPhotoProcess() {
		isIdPhoto = false;
		if (renderPhotoFileData()) {
			if (photoProcessSwitch) {
				// 已开启照片处理，直接替换照片文件
				$("#photoFileData").cropper("enable");
				$("#photoFileData").cropper("replace", photoFileDataObject.src);
			} else {
				// 未开启照片处理
				$("#photoFileData").cropper({
					aspectRatio: photoWith / photoHeight,
					minContainerWidth: 600,
					minContainerHeight: 450,
					dragCrop: false,
					resizable: false,
					preview: "#photoPreview",
					crop: function(e) {
						document.getElementById("photoProcessData").value = e.x + "_" + e.y + "_" + e.width + "_" + e.height + "_" + (e.rotate < 0 ? 360 + e.rotate : e.rotate)
					}
				});
				photoProcessSwitch = true;
			}
		}
	}

	// 照片处理数据上传
	function photoProcessDataUpload() {
		if(isIdPhoto){
			if(!$("#photoFileData2").val()){
				jAlert("照片为空", "warning");
				return;
			}
			$.messager.confirm("系统消息", "您确定要上传选定的身份证照片？", function(r){
	        	if(r){
	        		$.messager.progress({text:"数据处理中，请稍后...."});
		     			$.ajaxFileUpload({
		            		url:"basicPhotoAction/basicPhotoAction!fileUpload.action",
		            		data:{
		            			personPhotoId:$("#customerId").val(),
		            			personPhotoContent:$("#photoFileData2").val()
		            		},
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
				          		}else{
				          			$.messager.alert("系统消息",data.errMsg,"error");
				          		}
				            }, error:function(data,status, e) {
		                 	    $.messager.progress("close");
		                        $.messager.alert("系统消息",data.errMsg,"error");
		                    }
		                });
	     	    }
	        });
		} else if (checkPhotoFile() && photoProcessSwitch) {
			$.messager.confirm("系统消息", "您确认要上传当前处理的照片？", function(e) {
				if (e) {
					$.messager.progress({text: "正在处理数据，请稍后..."});
					$.ajaxFileUpload({
						url: "basicPhotoAction/basicPhotoAction!photoProcessDataUpload.action?personPhotoId=" + $("#customerId").val() + "&photoProcessData=" + $("#photoProcessData").val(),
						secureuri: false,
						fileElementId: ["photoFile"],
						dataType: "json",
						success: function(data, status) {
							$.messager.progress("close");
							if (data.status == "0") {
								$.messager.alert("系统消息", "照片上传成功！", "info", function() {
									$.modalDialog.handler.dialog("close");
									$.modalDialog.handler = undefined;
									if(query){
										query();
									}
									$grid.datagrid("reload");
								});
							} else {
								$.messager.alert("系统消息", data.errMsg, "error");
							}
						},
						error: function(data, status, e) {
							$.messager.progress("close");
							$.messager.alert("系统消息",data.errMsg,"error");
						}
					});
				}
			});
		}
	}

	// 照片逆时针旋转90度处理
	function photoRotateAnticlockwise() {
		if (photoProcessSwitch) {
			try {
				$("#photoFileData").cropper("rotate", -90);
			} catch (e) {
				$.messager.alert("系统消息", "当前浏览器不支持照片逆时针旋转90度处理！", "info");
			}
		}
	}

	// 照片顺时针旋转90度处理
	function photoRotateClockwise() {
		if (photoProcessSwitch) {
			try {
				$("#photoFileData").cropper("rotate", 90);
			} catch (e) {
				$.messager.alert("系统消息", "当前浏览器不支持照片顺时针旋转90度处理！", "info");
			}
		}
	}

	// 照片缩小处理
	function photoZoomOut() {
		if (photoProcessSwitch) {
			try {
				$("#photoFileData").cropper("zoom", photoZoom - 0.1);
			} catch (e) {
				$.messager.alert("系统消息", "当前浏览器不支持照片缩小处理！", "info");
			}
		}
	}

	// 照片放大处理
	function photoZoomIn() {
		if (photoProcessSwitch) {
			try {
				$("#photoFileData").cropper("zoom", photoZoom + 0.1);
			} catch (e) {
				$.messager.alert("系统消息", "当前浏览器不支持照片放大处理！", "info");
			}
		}
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
    			if(photoProcessSwitch){
    				$("#photoFileData").cropper("disable");
    			}
		    	$("#photoPreview").empty().append("<img src='" + data.imageMsg + "' height='100%'>");
		    	$("#photoFileData2").val(o["photo"]);
		    	isIdPhoto = true;
			}else{
				jAlert(data.errMsg);
			}
	  	});
    }
</script>
<div class="easyui-layout" style="width: 850px; height: 550px;" data-options="fit: true, border: false">
	<form id="form" action="#" method="post" enctype="multipart/form-data">
		<!-- 客户编号 -->
		<input type="hidden" id="customerId" name="customerId" />
		<input type="hidden" id="photoFileData2">
		<!-- 照片处理数据 -->
		<input type="hidden" id="photoProcessData" name="photoProcessData" />
		<div style="overflow: hidden; padding: 10px; padding-left: 10px; padding-right: 5px; width: 600px;" data-options="region: 'center', border: false">
			<!-- 照片文件框 -->
			<p>
				选择照片：
				<input style="width: 400px;" type="file" id="photoFile" name="file" onchange="openPhotoProcess();" />
				&nbsp;<a href="javascript:void(0)" class="easyui-linkbutton" iconCls="icon-readIdcard" plain="false" onclick="readIDCard2();">读取身份证</a>
			</p>
			<!-- 照片处理区域 -->
			<div style="height: 450px; width: 600px; background: #EEEEEE; overflow: hidden;">
				<img id="photoFileData" name="photoFileData" />
			</div>
		</div>
		<div style="overflow: hidden; padding: 10px; padding-left: 5px; padding-right: 10px; padding-top: 50px; width: 200px;" data-options="region: 'east', border: false">
			<!-- 预览区域 -->
			<p>预览</p>
			<div id="photoPreview" style="height: 220px; width: 180px; background: #EEEEEE; overflow: hidden;"></div>
			<p style="color: red;">*请正确选择您要导入的照片文件，其中照片文件类型为jpg格式，照片文件大小不能超过500KB。如果该客户已经存在照片，导入的照片将会覆盖该客户原先的照片*</p>
		</div>
		<div style="overflow: hidden; padding: 10px; height: 50px;" data-options="region: 'south', border: false">
			<!-- 工具按钮 -->
			<a class="easyui-linkbutton" data-options="iconCls: 'icon-rotate_anticlockwise', plain: false" href="javascript:void(0);" onclick="photoRotateAnticlockwise();">逆时针旋转90度</a>
			<a class="easyui-linkbutton" data-options="iconCls: 'icon-rotate_clockwise', plain: false" href="javascript:void(0);" onclick="photoRotateClockwise();">顺时针旋转90度</a>
			<a class="easyui-linkbutton" data-options="iconCls: 'icon-zoom_out', plain: false" href="javascript:void(0);" onclick="photoZoomOut();">缩小</a>
			<a class="easyui-linkbutton" data-options="iconCls: 'icon-zoom_in', plain: false" href="javascript:void(0);" onclick="photoZoomIn();">放大</a>
		</div>
	</form>
</div>