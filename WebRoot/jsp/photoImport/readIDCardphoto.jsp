<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	
	
  
        
        function fileUpload() {
              $.messager.confirm('确认对话框', '你确定要上传照片？', function(r){
            	  if (r){
            		  $.messager.progress({
							title : '提示',
							text : '数据处理中，请稍后....'
						});
            		  $.post("basicPhotoAction/basicPhotoAction!fileUpByIDCard.action",$("#form").serialize(),function(data,status){
         				 $.messager.progress('close');
         				 if(status == "success"){
         					 $.messager.alert("系统消息",data.errMsg,(data.status == "0" ? "info" : "error"),function(){
         						 if(data.status == "0"){
         							$.messager.progress('close');
                              	  if(typeof($dg) != "undefined") {
                              	  	$dg.datagrid("reload");
                              	  }
                              	  if($("#certNo") != null) {
                              		imgDeal.getImgMessageByCertNo($("#certNo").val(),function(data){
                    	       		 		dwr.util.setValue("imgPhoto",data.imageMsg);
                    	       		 	});
                              	  }
                              	  if(data.status == "0") {
                              	  	$.modalDialog.handler.dialog('close');
                              	  }
                              	  $("#preview").attr("src","");
                                    $.messager.alert('消息提示',data.errMsg,'info');
         							 $dg.datagrid("reload");
         							 $.modalDialog.handler.dialog('destroy');
         							 $.modalDialog.handler = undefined;
         						 }
         					 });
         				 }else{
         					 $.messager.alert("系统消息", data.errMsg,"error");
         					 return;
         				 }
         			 },"json");
            	  }
              });
             
        } 
        
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" action="" enctype="multipart/form-data">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>照片预览</legend>
				<input name="personPhotoContent" id="personPhotoContent" class="textinput" type="hidden" />
				 <div data-options="region:'center',border:true" title="" style="height:auto;overflow: hidden;padding: 10px;text-align:center;">
                            <table>
                                <tr>
                                    <th>证件号码：</th>
                                    <td><input id="certNo1" style="width:550px"  name="certNo"  class="textinput"/></td>
                                 </tr>
                            </table>
                                <hr size=8 style="COLOR: #ffd306;border-style:outset;width:490;"> 
                                <div >
                                    <h4 style="position: absolute; left: 0.1in;">预　　 览：</h4>
                                </div>
                                <div id="localImag" style="width:120px;height:160px;" overfold:hidden;padding-left:10px;">  
                                    <%--预览，默认图片--%>  
                                    <img id="preview" style="width:120px;height:160px;padding-left:60px;" onclick="over(preview,divImage,imgbig);" />   
                                </div> 
            	</div>  
			</fieldset>
		</form>
	</div>
</div>
