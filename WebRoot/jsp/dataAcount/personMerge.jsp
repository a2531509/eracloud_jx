<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>

<style>
#searchConts table tr td{
	border:none;
}
img {
	border:3px solid #ffff33
}
img:HOVER {
	border:3px solid #99ff00
}
img.select {
	border:3px solid #00ff00
}
</style>
<script type='text/javascript' src='dwr/interface/imgDeal.js'></script>
<script type="text/javascript">
	var hasPhoto = false;
	var hasPhoto2 = false;
	$(function(){
		$.extend($.fn.validatebox.defaults.rules, {
		    personalId: {
		        validator: function(value){    
		            var medWholeNo = value.substring(0, 6);
		            if(medWholeNo != "330499" && medWholeNo != "330421" && medWholeNo != "330424" 
		            		&& medWholeNo != "330481" && medWholeNo != "330482" && medWholeNo != "330483"){
		            	return false;
		            }
		            return true;
		        },
		        message: "社保编码需加上 6 位统筹区代码"
		    }    
		});  
		
		$("img").bind("click", function(){
			$("img").removeClass("select");
			$(this).addClass("select");
			if($("#photo1.select").get(0)){
				$("#photo").val($("#certNo1").val());
			} else if($("#photo2.select").get(0)){
				$("#photo").val($("#certNo2").val());
			}
		});
		
		$("#searchConts").form({
			url : "dataAcount/dataAcountAction!personMerge.action",
			onSubmit : function() {
				if (!$("#searchConts").form("validate")) {
					return false;
				}
				var certNo1 = $("#certNo1").val();
				var certNo2 = $("#certNo2").val();
				if(certNo1 == certNo2){
					jAlert("证件号码不能相同!", "warning");
				}
				if(hasPhoto && !hasPhoto2){
					$("#photo").val($("#certNo1").val());
				} else if(!hasPhoto && hasPhoto2){
					$("#photo").val($("#certNo2").val());
				}
				if((hasPhoto || hasPhoto) && !$("#photo").val()){
					jAlert("请选择照片!", "warning");
				}
			},
			success : function(data) {
				var info = JSON.parse(data);

				if (info.status == "1") {
					$.messager.alert("消息提示", info.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "人员合并保存成功", "info", function() {
						$("#save-button").linkbutton("disable");
					});
				}
			}
		});
	});
	
	function query(){
		if(!$("#searchConts").form("validate")){
			return false;
		}
		var certNo1 = $("#certNo1").val();
		var certNo2 = $("#certNo2").val();
		imgDeal.getImgMessageByCertNo(certNo1,function(data){
			if(data.imageMsg){
		 		hasPhoto = true;
		 		dwr.util.setValue("photo1",data.imageMsg);
		 		$("#photo1").show();
			} else {
				hasPhoto = false;
				$("#photo1").hide();
			}
	 	});
		imgDeal.getImgMessageByCertNo(certNo2,function(data){
			if(data.imageMsg){
		 		hasPhoto2 = true;
		 		dwr.util.setValue("photo2",data.imageMsg);
		 		$("#photo2").show();
			} else {
				hasPhoto2 = false;
				$("#photo2").hide();
			}
	 	});
		$("#save-button").linkbutton("enable");
		$("img").removeClass("select");
		$("#photo").val("");
	}
	
	function save(){
		$("#searchConts").form("submit");
	}
</script>
<n:initpage title="人员信息进行合并！社保编码前需加上 6 位统筹区代码">
	<n:center>
		<div id="tb" class="datagrid-toolbar" style="height: 100%">
			<form id="searchConts" method="post">
				<input id="photo" type="hidden" name="photoCertNo">
				<table class="tablegrid" style="width: auto; border: none; margin: 0 auto;">
					<tr>
						<td class="subtitle" colspan="2" style="width: 300px">正确信息</td>
						<td class="subtitle" colspan="2" style="width: 300px">错误信息</td>
					</tr>
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo1" type="text"  name="certNo1" class="textinput easyui-validatebox" required="required" maxlength="18"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo2" type="text"  name="certNo2" class="textinput easyui-validatebox" required="required" maxlength="18"/></td>
					</tr>
					<tr>
						<td class="tableleft">社保编码：</td>
						<td class="tableright"><input id="personalId1" type="number" class="textinput easyui-validatebox" data-options="required:true,validType:'personalId'" name="personalId1"/></td>
						<td class="tableleft">社保编码：</td>
						<td class="tableright"><input id="personalId2" type="number" class="textinput" name="personalId2"/></td>
					</tr>
					<tr>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input  id="name1" type="text" name="name1" class="textinput easyui-validatebox" required="required"/></td>
						<td class="tableleft">姓名：</td>
						<td class="tableright">
							<input  id="name2" type="text" name="name2" class="textinput"/>&nbsp;
						</td>
						<td class="tableright">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a id="save-button" style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save',disabled:true" href="javascript:void(0);" class="easyui-linkbutton" onclick="save()">保存</a>
						</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align: center;">
							<img id="photo1" style="width:120px;height:160px;vertical-align:top;display: none;" src="images/defaultperson.gif" alt=""/>
						</td>
						<td colspan="2" style="text-align: center;">
							<img id="photo2" style="width:120px;height:160px;vertical-align:top;display: none;" src="images/defaultperson.gif" alt=""/>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</n:center>
</n:initpage>