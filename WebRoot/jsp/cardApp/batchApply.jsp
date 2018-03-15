<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		$("#import_dialog").dialog({
			title : "导入数据",
			width : 400,
		    height : 185,
		    modal: true,
		    closed : true,
			onClose : function(){
			},
			onBeforeOpen : function(){
				$("#file2")[0].value = "";
			}
		});
		$("#import_dialog2").dialog({
			title : "导入数据",
			width : 400,
		    height : 185,
		    modal: true,
		    closed : true,
			onClose : function(){
			},
			onBeforeOpen : function(){
				$("#file")[0].value = "";
			}
		});
		
		$("#dia3").dialog({
    		title:"申领历史",
    		fit:true,
    		closed:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
    			$("#dg4").datagrid("load", {query : true});
    		}
    	});
		
		$("#dg4").datagrid({
            url:"cardapply/cardApplyAction!batchApplySnapBatch.action",
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            fitColumns:true,
            fit:true,
            singleSelect:false,
            pageList:[50, 100, 200, 500, 1000],
            scrollbarSize:0,
            autoRowHeight:true,
            columns:[[
            	{field:"",sortable:true,checkbox:true},
		 		{field:"BATCH_NO",title:"序号",sortable:true,width:parseInt($(this).width()*0.05)},
		 		{field:"CORP_NUM",title:"单位数量",sortable:true},
		 		{field:"NO_APP_NUM",title:"未申领人员总数",sortable:false},
		 		{field:"CAN_APP_NUM",title:"符合申领人员总数",sortable:false},
		 		{field:"APP_NUM",title:"申领成功人员总数",sortable:false},
		 		{field:"APPLYDATE",title:"申领日期",sortable:false,width:parseInt($(this).width()*0.08), formatter:function(v, r, i){
		 			if(r.BATCH_NO && r.BATCH_NO.length >= 14){
		 				return r.BATCH_NO.substring(0, 4) + "-" + r.BATCH_NO.substring(4, 6) + "-" + r.BATCH_NO.substring(6, 8) + " " + r.BATCH_NO.substring(8, 10) + ":" + r.BATCH_NO.substring(10, 12) + ":" + r.BATCH_NO.substring(12, 14);
		 			}
		 		}},
		 		{field:"APP_BRCH",title:"申领网点",sortable:false,width:parseInt($(this).width()*0.1)},
		 		{field:"APP_USER",title:"申领柜员",sortable:false,width:parseInt($(this).width()*0.05)}
         	]],
            onBeforeLoad:function(param){
            	if(!param.query){
            		return false;
            	}
            	return true;
            },
            onLoadSuccess:function(data){
                if(data.status == 1){
                    $.messager.alert("系统消息",data.errMsg,"warning");
            	}
        	},
        	toolbar: "#tb3"
        });
		
		$("#dia").dialog({
    		title:"单位申领历史",
    		fit:true,
    		closed:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
	    		var selections = $("#dg4").datagrid("getSelections");
	    		if(!selections || selections.length != 1){
	    			jAlert("请选择一个批次", "warning");
	    			return false;
	    		}
	    		var batchNo = selections[0].BATCH_NO;
    			var params = {};
    			params["queryType"] = true;
    			params["selectedId"] = batchNo;
    			$("#dg2").datagrid("load", params);
    		}
    	});
		
		$("#dg2").datagrid({
            url:"cardapply/cardApplyAction!batchApplySnapSearch.action",
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            fitColumns:true,
            fit:true,
            singleSelect:false,
            pageList:[50, 100, 200, 500, 1000],
            scrollbarSize:0,
            autoRowHeight:true,
            columns:[[
            	{field:"SELECTID",sortable:true,checkbox:true},
		 		{field:"CORP_ID",title:"单位编号",sortable:true,width:parseInt($(this).width()*0.05)},
		 		{field:"CORP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width()*0.1)},
		 		{field:"NO_APP_NUM",title:"未申领人员总数",sortable:false},
		 		{field:"CAN_APP_NUM",title:"符合申领人员总数",sortable:false},
		 		{field:"APP_NUM",title:"申领成功人员总数",sortable:false},
		 		{field:"APPLYDATE",title:"申领日期",sortable:false,width:parseInt($(this).width()*0.08)},
		 		{field:"APPLY_BRCH",title:"申领网点",sortable:false,width:parseInt($(this).width()*0.1)},
		 		{field:"APPLY_USER",title:"申领柜员",sortable:false,width:parseInt($(this).width()*0.05)}
         	]],
            onBeforeLoad:function(param){
            	if(!param.queryType){
            		return false;
            	}
            	return true;
            },
            onLoadSuccess:function(data){
                if(data.status == 1){
                    $.messager.alert("系统消息",data.errMsg,"warning");
            	}
        	},
        	toolbar: "#tb2"
        });
		
		$("#dia2").dialog({
    		title:"单位申领历史明细",
    		fit:true,
    		closed:true,
    		collapsible:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
	    		var selections = $("#dg2").datagrid("getSelections");
	    		if(!selections || selections.length != 1){
	    			jAlert("请选择一条记录", "warning");
	    			return false;
	    		}
    			var dealNo = selections[0].DEAL_NO;
    			$("#dg3").datagrid("load", {"rec.dealNo" : dealNo, query : true});
    		}
    	});
		
		$("#dg3").datagrid({
			url:"cardapply/cardApplyAction!viewAppSnapDetail.action",
			pagination:true,
	     	rownumbers:true,
			border:false,
	 		striped:true,
	     	fitColumns:true,
	     	fit:true,
	       	singleSelect:false,
	   		pageList:[50, 100, 200, 500, 1000],
	       	scrollbarSize:0,
	       	autoRowHeight:true,
			frozenColumns:[[
			    	{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width()*0.08)},
			    	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.08)},
			    	{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.06)},
			    	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.13)},
			    	]],
			columns:[[
			    	{field:"CORP_NAME",title:"单位",sortable:true},
			    	{field:"REGION_NAME",title:"所属区域",sortable:true},
			    	{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true},
			    	{field:"COMM_NAME",title:"社区（村）",sortable:true},
			    	{field:"MOBILE_NO",title:"联系电话",sortable:true},
			    	{field:"SURE_FLAG",title:"备注",sortable:false, formatter:function(value){
			    		if(value == '1') {
			    			return "<span style='color:green'>可申领</span>";
			    		} else if(value == '2') {
			    			return "<span style='color:red'>人员状态不正常</span>";
			    		} else if(value == '3') {
			    			return "<span style='color:red'>参保信息不存在或参保状态不正常</span>";
			    		} else if(value == '4') {
			    			return "<span style='color:red'>照片不存在或照片状态不正常</span>";
			    		}
			    		return "<span style='color:yellow'>" + value + "</span>";
			    	}},
			    	{field:"APPLYSTATE",title:"申领状态",sortable:true, formatter:function(v, r, i){
			    		if(r.SURE_FLAG == 1){
			    			if(!v){
				    			return "未申领或已撤销";
			    			} else {
			    				return v;
			    			}
			    		}
			    		return;
			    	}}
			    ]],
			onBeforeLoad:function(param){
	          	if(!param.query){
	            	return false;
	          	}
	          	return true;
	     	},
		 	toolbar:[{
				text:'导出',
				iconCls:'icon-export',
				handler:function(){
					exportAppSnapDetail();
				}
			}],
            onLoadSuccess:function(data){
                if(data.status == 1){
                    $.messager.alert("系统消息",data.errMsg,"warning");
            	}
        }});
		
		$("#synGroupId").switchbutton({
			width:45,
			value:"0",
            checked:false,
            onText:"是",
            offText:"否",
			onChange:function(checked){
				isDivide();
			}
		});
		createLocalDataSelect({
			id:"isJudgeSbState",
			data:[
			    {value:"0",text:"是"},
			    {value:"1",text:"否"}
			],
			value:"0"
		});
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>温馨提示：<br/>任务的最小单位是否自动到组：<br/>是：任务将以组单位为生成制卡任务信息<br/>否：任务将以社区（村）为单位生成制卡任务信息</span>" 
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			value:"<%=com.erp.util.Constants.CARD_TYPE_SMZK%>",
			isShowDefaultOption:false
		});
		createSysCode({
			id:"corpType",
			codeType:"CORP_TYPE"
		});
		createCustomSelect({
			id:"corpRegionId",
			value:"city_id",
			text:"city_name",
			table:"base_city",
			where:"nvl(city_type,'1') <> '2'",
			orderby:"city_id desc",
			from:1,
			to:20
		});
		$.autoComplete({
			id:"companyNo",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:1
		},"companyName");
		$.autoComplete({
			id:"companyName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:1
		},"companyNo");
		/* createLocalDataSelect({
			id:"isPhoto",
			value:"0",
		    data:[
		        {value:"0",text:"是"},
		        {value:"1",text:"否"}
		    ]
		}); */
		//$(".on_off_checkbox").iphoneStyle();
		createSysCode({
			id:"applyWay",
		    codeType:"APPLY_WAY",
		    codeValue:"1,2",
		    isShowDefaultOption:false,
		    value:"1",
		    onSelect:function(node){
		    	$grid.datagrid("loadData",{total:0,rows:[],status:"0"});
		 		if(node.VALUE == "2"){
		 			$("#sqapply").show();
		 			$("#dwapply").hide();
		 			$("#schapply").hide();
		 			$("#dwAddBtn").hide();
		 			$("#importCorp").hide();
		 			$("#file").hide();
		 			$("#viewAppSnap").hide();
		 			$grid.datagrid({
		 				queryParams:{queryType:"1"},
		 				columns:[[
		 			      	{field:"SELECTID",sortable:true,checkbox:true},
		 			    	{field:"REGION_NAME",title:"所属区域名称",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"COMM_NAME",title:"社区（村）",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"GROUP_NAME",title:"村组",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"TOTNUMS",title:"符合申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)}
		 			    ]]
		 			});
		 		}else if(node.VALUE == "1"){
		 			$("#sqapply").hide();
		 			$("#dwapply").show();
		 			$("#schapply").hide();
		 			$("#dwAddBtn").show();
		 			$("#importCorp").show();
		 			$("#file").show();
		 			$("#viewAppSnap").show();
		 			$grid.datagrid({
		 				queryParams:{queryType:"1"},
		 				columns:[[
		 			      	{field:"SELECTID",sortable:true,checkbox:true},
		 			    	{field:"CORP_CUSTOMER_ID",title:"单位编号",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"CORP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"ABBR_NAME",title:"单位简称",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"CORP_TYPE",title:"单位类型",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"NO_APP_NUM",title:"未申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)},
		 			    	{field:"TOTNUMS",title:"符合申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)}
		 			    ]]
		 			});
		 		}else if(node.VALUE == "3"){
		 			$("#sqapply").hide();
		 			$("#dwapply").hide();
		 			$("#schapply").show();
		 			$("#dwAddBtn").hide();
		 			$grid.datagrid({
		 				queryParams:{queryType:"1"},
		 				columns:[[
		 			      	{field:"SELECTID",sortable:true,checkbox:true},
		 			    	{field:"CORP_CUSTOMER_ID",title:"学校名称",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"CORP_NAME",title:"年级",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"ABBR_NAME",title:"班级",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"CORP_TYPE",title:"",sortable:true,width:parseInt($(this).width()*0.1)},
		 			    	{field:"TOTNUMS",title:"符合申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)}
		 			    ]]
		 			});
		 		}
		 	}
		});
		createLocalDataSelect({
			id:"makeCardWay",
		    data:[
		        {value:"0",text:"本地制卡"},
		        {value:"1",text:"外包制卡"}
		    ],
		    value:"1"
		});
		createRegionSelect(
			{id:"regionId",panelMaxHeight:200},
			{id:"townId"},
			{
				id:"commId",
			    onSelect:function(node){
		    		$("#groupId").combobox("clear");
		    		$("#groupId").combobox("reload","commAction!getAllGroup.action?comm_Id=" + node.comm_Id);
		    	},
		    	onLoadSuccess:function(){
			 		var cys = $("#commId").combobox("getData");
			 		if(cys.length > 0){
			 			$("#commId").combobox("setValue",cys[0].comm_Id);
			 			$("#groupId").combobox("clear");
			 			$("#groupId").combobox("reload","commAction!getAllGroup.action?comm_Id=" + cys[0].comm_Id);
			 		}
			    }
			}
		);
		$("#groupId").combobox({ 
		    editable:false,
		    cache: false,
		    multiple:false,
		    panelHeight:"auto",
		    panelMaxWidth:174,
		    panelMaxHeight:200,
		    valueField:"group_Id",   
		    textField:"group_Name"
 		});	
		$("#schoolId").combobox({ 
		    url:"commAction!getAllSchool.action",
		    editable:false,
		    cache: false,
		    panelHeight:"auto",
		    valueField:"school_Id",   
		    textField:"school_Name",
	    	onSelect:function(node){
	    		$("#gradeId").combobox("clear");
	    		$("#gradeId").combobox("reload","commAction!getAllGrade.action?school_Id="+node.school_Id);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#schoolId").combobox("getData");
		 		if(cys.length > 0){
		 			$(this).combobox("setValue",cys[0].school_Id);
		 			$("#gradeId").combobox("reload","commAction!getAllGrade.action?school_Id=" + cys[0].school_Id);
		 		}
		    }
 		}); 
		$("#gradeId").combobox({ 
		    editable:false,
		    cache: false,
		    panelHeight:"auto",
		    valueField:"grade_Id",   
		    textField:"grade_Name",
		    onSelect:function(node){
	    		$("#classesId").combobox("clear");
	    		$("#classesId").combobox("reload","commAction!getAllGrade.action?grade_Id=" + node.grade_Id);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#classesId").combobox("getData");
		 		if(cys.length > 0){
		 			$(this).combobox("setValue",cys[0].grade_Id);
		 			$("#classesId").combobox("clear");
		 			$("#classesId").combobox("reload","commAction!getAllGrade.action?grade_Id=" + cys[0].grade_Id);
		 		}
		    }
 		});
		$("#classesId").combobox({ 
		    editable:false,
		    cache: false,
		    valueField:"classes_Id",   
		    textField:"classes_Name"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"cardapply/cardApplyAction!batchApplySearch.action",
			fit:true,
			border:false,
			pageList:[20,50,100,500,1000,2000],
			singleSelect:false,
			ctrlSelect:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
		      	{field:"SELECTID",sortable:true,checkbox:true},
		    	{field:"CORP_CUSTOMER_ID",title:"单位编号",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"CORP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"ABBR_NAME",title:"单位简称",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"CORP_TYPE",title:"单位类型",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"NO_APP_NUM",title:"未申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)},
		    	{field:"TOTNUMS",title:"符合申领人员总数",sortable:false,width:parseInt($(this).width()*0.1)}
		    ]]
		});
	});
	function toQuery(){
		var away = $("#applyWay").combobox("getValue");
		if(away == "1" || away == "2" || away == "3"){
			if(away == "2"){
				if(dealNull($("#regionId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请选择人员所属区域","error",function(){
						$("#regionId").combobox("showPanel");
					});
					return;
				}
				if(dealNull($("#townId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请选择人员所属乡镇（街道）","error",function(){
						$("#townId").combobox("showPanel");
					});
					return;
				}
			}else if(away == "1"){
				if(dealNull($("#companyNo").val()) == "" && dealNull($("#corpType").combobox("getValue")) == "" && dealNull($("#corpRegionId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请输入单位编号, 单位类型或单位所属区域！","error",function(){
					    $("#corpType").combobox("showPanel");
					});
					return;
				}
			}else if(away == "3"){
				if(dealNull($("#schoolId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","已选择学校申领，请选择学校名称！","error");
					return;
				}
				if(dealNull($("#gradeId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","已选择学校申领，请选择班级！","error");
					return;
				}
			}
			var params = getformdata("searchConts");
			params["queryType"] = "0";
			params["companyNo"] = $("#companyNo").val();
			params["companyName"] = $("#companyName").val();
			//alert($("#searchConts").serialize());
			//return;
			$grid.datagrid("load",params);
		}else{
			$.messager.alert("系统消息","请选择申领方式！","error");
			return;
		}
	}
	function deleteRow(){
		var selectedRow = $grid.datagrid("getSelected");
		if(!selectedRow){
			$.messager.alert("系统消息","请选择一条记录进行删除！","error");
			return;
		}
		var tempindex = $grid.datagrid("getRowIndex",selectedRow);
		$grid.datagrid("deleteRow",tempindex);
		if(tempindex == 0){
			var allch = $(":checkbox").get(0);
	 		if(allch){
	 			allch.checked = false;
	 		}
		}
	}
    function viewRowsOpenDlg(){
		var rows = $grid.datagrid("getChecked");
		if(!rows || rows.length != 1){
			$.messager.alert("系统消息","请勾选一条记录信息进行查看！","error");
			return;
		}
		$.modalDialog({
			title:"人员信息预览",
			iconCls:"icon-viewInfo",
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"/jsp/cardApp/batchApplyDetailView2.jsp?selectedId=" + escape(encodeURIComponent(rows[0].SELECTID)),
			tools:[{
				iconCls:"icon_cancel_01",
				handler:function(){
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
			    }
			}]
		});
	}
	function toApply(){
		var allRows = $grid.datagrid("getChecked");
		var selectIds  = "";
		if(!allRows || allRows.length < 1){
			$.messager.alert("系统消息","请勾选将要进行申领的记录信息！","error");
			return;
		}
		for(var d = 0;d < allRows.length;d++){
			selectIds += allRows[d].SELECTID + ",";
		}
		var selectIds = selectIds.substring(0,selectIds.length -1)
		if(selectIds.length == 0){
			$.messager.alert("系统消息","请勾选将要进行申领的记录信息！","error");
			return;
		}
		var tempTitle = "您确定要将所勾选的记录进行规模申领吗？<span style='color:red;'>制卡方式：" + $("#makeCardWay").combobox("getText");
		tempTitle = tempTitle + "，申领方式：" + $("#applyWay").combobox("getText");
		tempTitle = tempTitle + "，计划生成任务总个数：" + allRows.length + "个</span>";
		$.messager.confirm("系统消息",tempTitle,function(is){
			if(is){
				$.messager.progress({text : "正在进行申领，请稍后...."});
				var tempParams = getformdata("searchConts");
				$.post("cardapply/cardApplyAction!saveBatchApply.action",$("#searchConts").serialize() + "&selectedId=" + selectIds,function(data,status){
					$.messager.progress("close");
					if(status == "success"){
						if(data.status == "0"){
							var msg = data.errMsg;
							if(data.errList){
								var list = data.errList;
								for(var i in list){
									msg += "<br>" + list[i];
								}
							}
						    $.messager.alert("系统消息",msg,"info",function(){
						    	$grid.datagrid("reload");
						    });
						}else{
							$.messager.alert("系统消息",data.errMsg,"error",function(){
								if(dealNull(data["sucNum"]) > 0){
									$grid.datagrid("reload");
								}
							});
						}
					}else{
						$.messager.alert("系统消息","规模申领出现错误，请重试！","error");
					}
				},"json");
			}
		});
	}
	function toAdd(){
		$.modalDialog({
			title:"申领单位新增",
			iconCls:"icon-viewInfo",
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"/jsp/cardApp/batchApplyAdd.jsp",
			tools:[{
				iconCls:"icon_cancel_01",
				handler:function(){
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
			    }
			}],
			buttons:[ 
		        {text:"确定",iconCls:"icon-ok",handler:function(){saveAllCorps();}},
				{text:"关闭",iconCls:"icon-cancel",handler:function(){
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					}
		        }
			]
		});
	}
	//是否自动分组
	function isDivide(){
		var chk = document.getElementById('synGroupId');
		if(chk.checked == true){
			$("#groupId").combobox('readonly',true);
		}else{
			$("#groupId").combobox('readonly',false);
		}
	}
	
	function importCorp() {
		var val = $("#file").val();
		if(!val){
			jAlert("请选择导入文件", "warning");
			return;
		}
		var params = getformdata("searchConts");
		params.rows = 1000;
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.ajaxFileUpload({  
            url:"cardapply/cardApplyAction!batchApplyImportSearch.action",
            fileElementId:['file'],
            data: params,
            dataType:"json",
            success: function(data, status){
            	$.messager.progress("close");
            	if(data.status == '1'){
            		jAlert("导入单位失败，" + data.errMsg, "warning");
        			return;
            	}
            	$("#import_dialog2").dialog("close");
            	var pager = $grid.datagrid("getPager");
            	pager.pagination({pageSize:1000});
            	$grid.datagrid('loadData', data);
            }
        });
	}
	
	function importCorpPerson() {
		var val = $("#file2").val();
		if(!val){
			jAlert("请选择导入文件", "warning");
			return;
		}
		var params = getformdata("searchConts");
		params.rows = 1000;
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.ajaxFileUpload({  
            url:"cardapply/cardApplyAction!saveImportBatchApply.action",
            fileElementId:['file2'],
            data: params,
            dataType:"json",
            success: function(data, status){
            	$.messager.progress("close");
            	if(data.status == '1'){
            		jAlert("导入单位人员失败，" + data.errMsg, "error");
        			return;
            	}
            	jAlert("导入单位人员申领成功", "info");
            }
        });
	}
	
	function viewAppSnapBatch() {
		$("#dia3").dialog("open");
	}
	
	function viewSnapDetail() {
		$("#dia2").dialog("open");
	}
	
	function exportAppSnapDetail() {
		var selections = $("#dg2").datagrid("getSelections");
		var dealNo = selections[0].DEAL_NO;
		$.messager.progress({text:"数据处理中..."});
		$('#download').attr('src',"cardapply/cardApplyAction!exportAppSnapDetail.action?rows=65530&rec.dealNo=" + dealNo);
		startCycle();
	}

	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportAppSnapDetail",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	
	function queryAppSnapBatch(){
		var params = {};
		params["query"] = true;
		params["beginTime"] = $("#applyDateStart").val();
		params["endTime"] = $("#applyDateEnd").val();
		$("#dg4").datagrid("load", params);
	}
	
	function viewAppSnap(){
		$("#dia").dialog("open");
	}
	
	function downloadTemplate2(){
		$("#import_dialog2").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=batchApplyImportCorp");
	}
	function downloadTemplate(){
		$("#import_dialog").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=batchApplyImportCorpPerson");
	}
	function openDialog(){
		$("#import_dialog").dialog("open");
	}
	function openDialog2(){
		$("#import_dialog2").dialog("open");
	}
</script>
<n:initpage title="人员进行批量申领制卡操作！">
  	<n:center>
		<div id="tb">
			<form id="searchConts">
				<input name="isPhoto"   value="<%=com.erp.util.Constants.YES_NO_YES %>" id="isPhoto"   type="hidden"/>
				<input name="isBatchHf" value="<%=com.erp.util.Constants.YES_NO_NO %>"  id="isBatchHf" type="hidden"/>
		        <table class="tablegrid">
					<tr id="dwapply">
						<td class="tableleft">单位编号：</td>
						<td class="tableright"><input name="companyNo"  class="textinput" id="companyNo" type="text"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright" ><input name="companyName"  class="textinput" id="companyName" type="text"/></td>
						<td class="tableleft">单位类型：</td>
						<td class="tableright"><input id="corpType" type="text" class="easyui-combobox  easyui-validatebox" name="corpType" style="width:174px;cursor:pointer;"/></td>
						<td  class="tableleft">单位所属区域：</td>
						<td  class="tableright"><input name="corpRegionId"  class="textinput"  id="corpRegionId"  type="text"/></td>
					</tr>
					<tr id="schapply" style="display:none;">
						<td  class="tableleft">所属学校：</td>
						<td  class="tableright"><input name="schoolId"  class="easyui-combobox" id="schoolId" type="text" style="width:174px;"/></td>
						<td  class="tableleft">所属年级：</td>
						<td  class="tableright" ><input name="gradeId"  class="easyui-combobox" id="gradeId" type="text" style="width:174px;"/></td>
						<td  class="tableleft">所在班级：</td>
						<td  class="tableright"><input id="classesId" type="text" class="easyui-combobox" name="classesId" style="width:174px;cursor:pointer;"/></td>
						<td  colspan="2">&nbsp;</td>
					</tr>
					<tr id="sqapply" style="display:none;">
					 	<td  class="tableleft">所属区域：</td>
						<td  class="tableright"><input name="regionId" class="textinput"  id="regionId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft">乡镇（街道）：</td>
						<td  class="tableright"><input name="townId" class="textinput" id="townId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft">社区（村）：</td>
						<td  class="tableright"><input name="commId" class="textinput easyui-validatebox" id="commId" type="text" style="width:174px;" /></td>
						<td  class="tableleft">村组：</td>
						<td  class="tableright">
							<input name="groupId" class="textinput easyui-validatebox" id="groupId" type="text" style="width:174px;" />
						    <span id="synGroupIdTip">
						    	<input id="synGroupId" name="synGroupId" class="textinput easyui-validatebox" type="checkbox" />
						    </span>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="width:6%">卡类型：</td>
						<td class="tableright" style="width:17%"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" value="100" style="width:174px;cursor:pointer;"/></td>
						<td class="tableleft" style="width:8%">申领方式：</td>
						<td class="tableright" style="width:17%"><input name="applyWay"  class="textinput" id="applyWay" type="text" value="2"/></td>
						<td class="tableleft" style="width:7%">制卡方式：</td>
						<td class="tableright" style="width:17%"><input name="makeCardWay" class="textinput" id="makeCardWay" type="text" value="1"/></td>
						<td class="tableleft" style="width:8%">是否判断医保：</td>
						<td class="tableright"><input id="isJudgeSbState" type="text" class="textinput" name="isJudgeSbState"/></td>
					</tr>
					<tr>
						<td style="text-align:right;" colspan="8">
							<a id="importCorp" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-import'"  onclick="openDialog2()">导入单位</a>
					    	&nbsp;
							<a id="importCorpPerson" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-import'"  onclick="openDialog()">导入单位人员</a>
							&nbsp;
					    	<a id="viewAppSnap" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-viewInfo'"  onclick="viewAppSnapBatch()">查看历史</a>
					    	&nbsp;
					    	<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'"  onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-viewInfo'" onclick="viewRowsOpenDlg()">预览</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-remove'" onclick="deleteRow()">删除</a>
							<a id="dwAddBtn" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-add'"  onclick="toAdd()">添加</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'"  onclick="toApply()">确认</a>
					    </td>
					</tr>
					<!-- <tr>
						<td class="tableleft">是否选择照片：</td>
						<td class="tableright"><input name="isPhoto" data-options="tipPosition:'left',validType:'email',invalidMessage:'判断客户是否有照片，选择是,则客户必须有照片才能进行申领；否，则不进行判断。'" value="1" class="textinput easyui-validatebox" id="isPhoto" type="text"/></td>
					    <td class="tableleft">出生年月始：</td>
						<td class="tableright"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">出生年月止：</td>
						<td class="tableright"><input name="endTime" class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					    <td style="text-align:center;"colspan="2">
					    	<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'"  onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-viewInfo'" onclick="viewRowsOpenDlg()">预览</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-remove'" onclick="deleteRow()">删除</a>
							<a id="dwAddBtn" style="display:none;" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-add'"  onclick="toAdd()">添加</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'"  onclick="toApply()">确认</a>
					    </td>
					</tr> -->
			    </table>
		    </form>
		</div>
  		<table id="dg" title="批量申领制卡"></table>
  		<div id="dia" >
  			<div id="tb2" class="tablegrid">
  				<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-viewInfo'" onclick="viewSnapDetail()">预览</a>
  			</div>
        	<table id="dg2" style="width:100%"></table>
        </div>
        <div id="dia2" >
        	<table id="dg3" style="width:100%"></table>
        </div>
        <div id="dia3" >
        	<div id="tb3">
        		<span style="padding:0 10px; display:inline-block;">
	  				<label for="applyDateStart">申领时间：</label>
	  				<input id="applyDateStart" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/>&nbsp;&nbsp;—&nbsp;&nbsp;
	  				<input id="applyDateEnd" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/>
  				</span>
  				<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'"  onclick="queryAppSnapBatch()">查询</a>
  				<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-viewInfo'" onclick="viewAppSnap()">预览</a>
        	</div>
        	<table id="dg4" style="width:100%"></table>
        </div>
        <iframe id="download" style="display:none"></iframe>
        <div id="import_dialog" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  		<table width="100%">
				<tr>
					<td>
						<input id="file2" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
						<button onclick="importCorpPerson()">导入</button>
					</td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
  		</div>
  		<div id="import_dialog2" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  		<table width="100%">
				<tr>
					<td>
						<input id="file" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
						<button onclick="importCorp()">导入</button>
					</td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate2()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
  		</div>
	</n:center>
</n:initpage>